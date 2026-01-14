import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'widgets/info_card.dart';
import 'widgets/status_badge.dart';

final robinCatalog = Catalog([
  ...CoreCatalogItems.asCatalog().items,
  CatalogItem(
    name: 'InfoCard',
    dataSchema: Schema.object(
      properties: {
        'title': Schema.string(description: 'The title of the card'),
        'content': Schema.string(description: 'The main body text of the card'),
        'icon': Schema.string(
          description: 'An optional icon name (info, warning, check, error)',
          enumValues: ['info', 'warning', 'check', 'error'],
        ),
      },
      required: ['title', 'content'],
    ),
    widgetBuilder: (itemContext) {
      final properties = itemContext.data as Map<String, dynamic>;
      return InfoCard(
        title: properties['title'] ?? 'No Title',
        content: properties['content'] ?? 'No Content',
        icon: properties['icon'],
      );
    },
  ),
  CatalogItem(
    name: 'StatusBadge',
    dataSchema: Schema.object(
      properties: {
        'label': Schema.string(description: 'The text label on the badge'),
        'status': Schema.string(
          description: 'The status type (success, warning, error, info)',
          enumValues: ['success', 'warning', 'error', 'info'],
        ),
      },
      required: ['label', 'status'],
    ),
    widgetBuilder: (itemContext) {
      final properties = itemContext.data as Map<String, dynamic>;
      return StatusBadge(
        label: properties['label'] ?? 'Unknown',
        status: properties['status'] ?? 'info',
      );
    },
  ),
], catalogId: 'a2ui.org:standard_catalog_0_8_0');
