import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';

class PetDescription extends StatefulWidget {
  final PetEntity pet;

  const PetDescription({super.key, required this.pet});

  @override
  State<PetDescription> createState() => _PetDescriptionState();
}

class _PetDescriptionState extends State<PetDescription> {
  bool _isExpanded = false;
  final int _maxLines = 4;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final description = widget.pet.description;

    if (description.isEmpty) {
      return _buildEmptyDescription(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acerca de ${widget.pet.name}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildDescriptionCard(theme, description),
      ],
    );
  }

  Widget _buildEmptyDescription(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.description, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            'Sin descripción disponible',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'El dueño no ha proporcionado una descripción para ${widget.pet.name}.',
            style: theme.textTheme.bodyMedium?.copyWith(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ThemeData theme, String description) {
    final textSpan = TextSpan(
      text: description,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: theme.colorScheme.onSurface,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: _maxLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 80);

    final isOverflowing = textPainter.didExceedMaxLines;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Historia de ${widget.pet.name}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
                _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            firstChild: _buildCollapsedText(theme, description),
            secondChild: _buildExpandedText(theme, description),
          ),
          if (isOverflowing)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _isExpanded ? 'Ver menos' : 'Ver más',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          if (widget.pet.searchTags.isNotEmpty) _buildSearchTags(theme),
        ],
      ),
    );
  }

  Widget _buildCollapsedText(ThemeData theme, String description) {
    return Text(
      description,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: theme.colorScheme.onSurface,
      ),
      maxLines: _maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildExpandedText(ThemeData theme, String description) {
    return Text(
      description,
      style: theme.textTheme.bodyLarge?.copyWith(
        height: 1.6,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSearchTags(ThemeData theme) {
    final relevantTags =
        widget.pet.searchTags
            .where(
              (tag) =>
                  tag.length > 2 &&
                  !tag.contains(widget.pet.name.toLowerCase()),
            )
            .take(6)
            .toList();

    if (relevantTags.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Divider(color: theme.colorScheme.outline.withAlpha(20)),
        const SizedBox(height: 10),
        Text(
          'Características destacadas',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              relevantTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
