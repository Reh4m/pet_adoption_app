import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Tipos de notificación
// type NotificationType =
//   | "new_request"
//   | "request_accepted"
//   | "request_rejected"
//   | "adoption_completed"
//   | "new_message";

interface NotificationPayload {
  title: string;
  body: string;
  data: Record<string, string>;
}

/**
 * Obtiene los tokens FCM de un usuario
 */
async function getUserTokens(userId: string): Promise<string[]> {
  const userDoc = await db.collection("users").doc(userId).get();

  if (!userDoc.exists) {
    console.log(`Usuario ${userId} no encontrado`);
    return [];
  }

  const userData = userDoc.data();
  return userData?.fcmTokens || [];
}

/**
 * Obtiene información básica de un usuario
 */
// async function getUserInfo(
//   userId: string
// ): Promise<{ name: string; photoUrl?: string } | null> {
//   const userDoc = await db.collection("users").doc(userId).get();

//   if (!userDoc.exists) return null;

//   const userData = userDoc.data();
//   return {
//     name: userData?.name || "Usuario",
//     photoUrl: userData?.photoUrl,
//   };
// }

/**
 * Envía notificaciones a múltiples tokens
 */
async function sendNotifications(
  tokens: string[],
  payload: NotificationPayload
): Promise<void> {
  if (tokens.length === 0) {
    console.log("No hay tokens para enviar notificaciones");
    return;
  }

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: payload.title,
      body: payload.body,
    },
    data: payload.data,
    android: {
      notification: {
        channelId: "pet_adoption_channel",
        priority: "high",
        defaultSound: true,
        defaultVibrateTimings: true,
        icon: "@mipmap/ic_launcher",
      },
    },
  };

  try {
    const response = await messaging.sendEachForMulticast(message);
    console.log(
      `Notificaciones enviadas: ${response.successCount} éxitos, ${response.failureCount} fallos`
    );

    // Limpiar tokens inválidos
    if (response.failureCount > 0) {
      const invalidTokens: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          const errorCode = resp.error?.code;
          if (
            errorCode === "messaging/invalid-registration-token" ||
            errorCode === "messaging/registration-token-not-registered"
          ) {
            invalidTokens.push(tokens[idx]);
          }
        }
      });

      // Aquí podrías limpiar los tokens inválidos de la base de datos
      if (invalidTokens.length > 0) {
        console.log(`Tokens inválidos encontrados: ${invalidTokens.length}`);
      }
    }
  } catch (error) {
    console.error("Error enviando notificaciones:", error);
  }
}

/**
 * TRIGGER: Nueva solicitud de adopción creada
 * Envía notificación al dueño de la mascota
 */
export const onAdoptionRequestCreated = functions.firestore.onDocumentCreated(
  "adoption_requests/{requestId}",
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      console.log("No hay datos en el snapshot");
      return;
    }

    const requestData = snapshot.data();
    const requestId = snapshot.id;

    console.log(`Nueva solicitud de adopción: ${requestId}`);

    // Obtener información
    const ownerId = requestData.ownerId;
    const requesterName = requestData.requesterName || "Alguien";
    const petName = requestData.petName || "tu mascota";

    // Obtener tokens del dueño
    const ownerTokens = await getUserTokens(ownerId);

    // Preparar notificación
    const payload: NotificationPayload = {
      title: "🐾 Nueva solicitud de adopción",
      body: `${requesterName} quiere adoptar a ${petName}`,
      data: {
        type: "new_request",
        requestId: requestId,
        petId: requestData.petId || "",
        requesterId: requestData.requesterId || "",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
    };

    await sendNotifications(ownerTokens, payload);
  }
);

/**
 * TRIGGER: Solicitud de adopción actualizada
 * Envía notificaciones según el nuevo estado
 */
export const onAdoptionRequestUpdated = functions.firestore.onDocumentUpdated(
  "adoption_requests/{requestId}",
  async (event) => {
    const beforeData = event.data?.before.data();
    const afterData = event.data?.after.data();
    const requestId = event.params.requestId;

    if (!beforeData || !afterData) {
      console.log("No hay datos antes o después de la actualización");
      return;
    }

    // Solo procesar si el estado cambió
    if (beforeData.status === afterData.status) {
      return;
    }

    const newStatus = afterData.status;
    const requesterId = afterData.requesterId;
    const ownerId = afterData.ownerId;
    const petName = afterData.petName || "la mascota";

    console.log(`Solicitud ${requestId} cambió a estado: ${newStatus}`);

    let payload: NotificationPayload | null = null;
    let targetUserId: string | null = null;

    switch (newStatus) {
      case "accepted":
        // Notificar al solicitante que su solicitud fue aceptada
        targetUserId = requesterId;
        payload = {
          title: "🎉 ¡Solicitud aceptada!",
          body: `Tu solicitud para adoptar a ${petName} ha sido aceptada. ¡Puedes iniciar el chat!`,
          data: {
            type: "request_accepted",
            requestId: requestId,
            petId: afterData.petId || "",
            ownerId: ownerId,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };
        break;

      case "rejected":
        // Notificar al solicitante que su solicitud fue rechazada
        targetUserId = requesterId;
        payload = {
          title: "😔 Solicitud rechazada",
          body: `Tu solicitud para adoptar a ${petName} no fue aceptada`,
          data: {
            type: "request_rejected",
            requestId: requestId,
            petId: afterData.petId || "",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };
        break;

      case "completed":
        // Notificar al solicitante que la adopción se completó
        targetUserId = requesterId;
        payload = {
          title: "🏠 ¡Adopción completada!",
          body: `¡Felicidades! La adopción de ${petName} se ha completado. ¡Bienvenido a tu nuevo hogar, ${petName}!`,
          data: {
            type: "adoption_completed",
            requestId: requestId,
            petId: afterData.petId || "",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        };
        break;

      default:
        console.log(`Estado ${newStatus} no requiere notificación`);
        return;
    }

    if (payload && targetUserId) {
      const tokens = await getUserTokens(targetUserId);
      await sendNotifications(tokens, payload);
    }
  }
);

/**
 * TRIGGER: Nuevo mensaje en chat
 * Envía notificación al destinatario
 */
// export const onChatMessageCreated = functions.firestore.onDocumentCreated(
//   "chats/{chatId}/messages/{messageId}",
//   async (event) => {
//     const snapshot = event.data;
//     const chatId = event.params.chatId;

//     if (!snapshot) {
//       console.log("No hay datos en el snapshot");
//       return;
//     }

//     const messageData = snapshot.data();

//     if (!messageData) {
//       console.log("No hay datos en el mensaje");
//       return;
//     }

//     // Ignorar mensajes del sistema
//     if (messageData.type === "system") {
//       return;
//     }

//     const senderId = messageData.senderId;

//     // Obtener información del chat
//     const chatDoc = await db.collection("chats").doc(chatId).get();
//     if (!chatDoc.exists) {
//       console.log(`Chat ${chatId} no encontrado`);
//       return;
//     }

//     const chatData = chatDoc.data()!;

//     // Determinar el destinatario
//     const recipientId =
//       chatData.requesterId === senderId
//         ? chatData.ownerId
//         : chatData.requesterId;

//     // Obtener información del remitente
//     const senderInfo = await getUserInfo(senderId);
//     const senderName = senderInfo?.name || "Alguien";

//     // Formatear contenido del mensaje
//     let messagePreview = "";
//     switch (messageData.type) {
//       case "text":
//         messagePreview =
//           messageData.content?.substring(0, 50) || "Nuevo mensaje";
//         if ((messageData.content?.length || 0) > 50) {
//           messagePreview += "...";
//         }
//         break;
//       case "image":
//         messagePreview = "📷 Imagen";
//         break;
//       case "video":
//         messagePreview = "🎥 Video";
//         break;
//       default:
//         messagePreview = "Nuevo mensaje";
//     }

//     // Obtener tokens del destinatario
//     const recipientTokens = await getUserTokens(recipientId);

//     const payload: NotificationPayload = {
//       title: `💬 ${senderName}`,
//       body: messagePreview,
//       data: {
//         type: "new_message",
//         chatId: chatId,
//         senderId: senderId,
//         messageId: snapshot.id,
//         click_action: "FLUTTER_NOTIFICATION_CLICK",
//       },
//     };

//     await sendNotifications(recipientTokens, payload);
//   }
// );
