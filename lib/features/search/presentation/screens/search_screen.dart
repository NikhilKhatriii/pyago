import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/shared/widgets/empty_state.dart';
import '../../../../core/shared/widgets/pyago_badge.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  void _submit(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    ref.read(recentSearchesProvider.notifier).add(value);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final recents = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          decoration: const InputDecoration(
            hintText: 'Search people, content, communities…',
            border: InputBorder.none,
          ),
          onSubmitted: _submit,
          onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
        child: query.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  if (recents.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent', style: Theme.of(context).textTheme.titleMedium),
                        TextButton(
                          onPressed: () => ref.read(recentSearchesProvider.notifier).clear(),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    for (final r in recents)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history_rounded),
                        title: Text(r),
                        onTap: () {
                          _controller.text = r;
                          _submit(r);
                        },
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text('Suggested', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final s in searchSuggestions)
                        PyagoTag(
                          label: s,
                          onTap: () {
                            _controller.text = s;
                            _submit(s);
                          },
                        ),
                    ],
                  ),
                ],
              )
            : PyagoEmptyState(
                icon: Icons.search_rounded,
                title: 'No results for "$query"',
                message: 'Try different keywords, or check the spelling.',
              ),
      ),
    );
  }
}
