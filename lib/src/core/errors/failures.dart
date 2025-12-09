import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {}

class NetworkFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UserNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class WrongPasswordFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class WeakPasswordFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ExistingEmailFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class TooManyRequestsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class PasswordMismatchFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class NotLoggedInFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class EmailVerificationFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// Pets Failures
class PetNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// User Failures
class UserAlreadyExistsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidUserDataFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UnauthorizedUserOperationFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UserUpdateFailedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ProfileImageUploadFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// Adoption Request Failures
class AdoptionRequestNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class DuplicateAdoptionRequestFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidAdoptionRequestStatusFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class AdoptionRequestAccessDeniedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// Chat Failures
class ChatNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ChatAlreadyExistsFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class MessageNotFoundFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidChatParticipantFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ChatAccessDeniedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class MessageSendFailedFailure extends Failure {
  @override
  List<Object?> get props => [];
}

// Media Failures
class MediaUploadFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class InvalidMediaFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class MediaTooLargeFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class UnsupportedMediaTypeFailure extends Failure {
  @override
  List<Object?> get props => [];
}

class ThumbnailGenerationFailure extends Failure {
  @override
  List<Object?> get props => [];
}
