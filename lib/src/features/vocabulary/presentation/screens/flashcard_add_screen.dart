import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import '../controllers/flashcard_controller.dart';

class FlashcardAddScreen extends ConsumerStatefulWidget {
  const FlashcardAddScreen({super.key});

  @override
  ConsumerState<FlashcardAddScreen> createState() => _FlashcardAddScreenState();
}

class _FlashcardAddScreenState extends ConsumerState<FlashcardAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _hintController = TextEditingController();
  final _meaningController = TextEditingController();
  final _exampleController = TextEditingController();
  final _exampleTranslationController = TextEditingController();

  String _selectedCategory = '決算・IR (Earnings)';

  static const List<String> _categories = [
    '決算・IR (Earnings)',
    'M&A・DD (Valuation)',
    '投資銀行 (Capital Markets)',
    '会計・監査 (Accounting)',
    'CFO・財務 (Corporate Finance)',
    'マクロ経済 (Macroeconomics)',
    'その他 (Other)',
  ];

  @override
  void dispose() {
    _termController.dispose();
    _hintController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    _exampleTranslationController.dispose();
    super.dispose();
  }

  void _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(flashcardControllerProvider.notifier);

    await controller.addUserCard(
      term: _termController.text.trim(),
      hint: _hintController.text.trim(),
      meaning: _meaningController.text.trim(),
      example: _exampleController.text.trim(),
      exampleTranslation: _exampleTranslationController.text.trim(),
      category: _selectedCategory.split(' ')[0], // short name
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('金融単語カードを追加しました')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('金融単語カードの追加'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _termController,
                decoration: const InputDecoration(
                  labelText: '金融英単語 *',
                  hintText: '例: EBITDA',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '英単語を入力してください';
                  }
                  return null;
                },
              ),
              const Gap(14),
              TextFormField(
                controller: _meaningController,
                decoration: const InputDecoration(
                  labelText: '日本語訳 *',
                  hintText: '例: 利払い前・税引き前・減価償却前利益',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return '日本語訳を入力してください';
                  }
                  return null;
                },
              ),
              const Gap(14),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'カテゴリー *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                    });
                  }
                },
              ),
              const Gap(14),
              TextFormField(
                controller: _hintController,
                decoration: const InputDecoration(
                  labelText: 'ヒント / 補足文脈',
                  hintText: '例: M&Aにおける企業価値評価指標',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(14),
              TextFormField(
                controller: _exampleController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '実務例文 (英語)',
                  hintText: '例: The company\'s EBITDA margin improved to 25% this quarter.',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(14),
              TextFormField(
                controller: _exampleTranslationController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '例文の日本語訳',
                  hintText: '例: 当四半期のEBITDAマージンは25%に改善しました。',
                  border: OutlineInputBorder(),
                ),
              ),
              const Gap(24),
              ElevatedButton.icon(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text(
                  '単語カードを保存',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
