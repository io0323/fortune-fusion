import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/profile.dart';

const _prefectureCoords = <String, (double, double)>{
  '北海道': (43.0642, 141.3469),
  '青森県': (40.8244, 140.7400),
  '岩手県': (39.7036, 141.1527),
  '宮城県': (38.2688, 140.8721),
  '秋田県': (39.7186, 140.1023),
  '山形県': (38.2404, 140.3633),
  '福島県': (37.7500, 140.4675),
  '茨城県': (36.3418, 140.4469),
  '栃木県': (36.5657, 139.8836),
  '群馬県': (36.3904, 139.0603),
  '埼玉県': (35.8614, 139.6489),
  '千葉県': (35.6047, 140.1233),
  '東京都': (35.6762, 139.6503),
  '神奈川県': (35.4478, 139.6425),
  '新潟県': (37.9026, 139.0233),
  '富山県': (36.6959, 137.2136),
  '石川県': (36.5944, 136.6256),
  '福井県': (36.0652, 136.2217),
  '山梨県': (35.6636, 138.5686),
  '長野県': (36.6513, 138.1813),
  '岐阜県': (35.3912, 136.7223),
  '静岡県': (34.9769, 138.3831),
  '愛知県': (35.1802, 136.9066),
  '三重県': (34.7303, 136.5086),
  '滋賀県': (35.0045, 135.8686),
  '京都府': (35.0211, 135.7556),
  '大阪府': (34.6937, 135.5023),
  '兵庫県': (34.6913, 135.1830),
  '奈良県': (34.6851, 135.8328),
  '和歌山県': (34.2260, 135.1675),
  '鳥取県': (35.5036, 134.2381),
  '島根県': (35.4723, 133.0505),
  '岡山県': (34.6617, 133.9344),
  '広島県': (34.3853, 132.4553),
  '山口県': (34.1859, 131.4705),
  '徳島県': (34.0657, 134.5593),
  '香川県': (34.3400, 134.0433),
  '愛媛県': (33.8417, 132.7656),
  '高知県': (33.5597, 133.5311),
  '福岡県': (33.6064, 130.4181),
  '佐賀県': (33.2494, 130.2988),
  '長崎県': (32.7503, 129.8777),
  '熊本県': (32.7898, 130.7417),
  '大分県': (33.2382, 131.6126),
  '宮崎県': (31.9110, 131.4236),
  '鹿児島県': (31.5966, 130.5571),
  '沖縄県': (26.2124, 127.6809),
};

const _genderOptions = ['男性', '女性', 'その他', '未回答'];

class ProfileFormWidget extends StatefulWidget {
  const ProfileFormWidget({
    super.key,
    required this.initialProfile,
    required this.onSave,
    this.isSaving = false,
  });

  final Profile? initialProfile;
  final void Function(Profile) onSave;
  final bool isSaving;

  @override
  State<ProfileFormWidget> createState() => _ProfileFormWidgetState();
}

class _ProfileFormWidgetState extends State<ProfileFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _birthPlaceCtrl;

  late String _gender;
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  bool _birthTimeUnknown = false;
  double? _lat;
  double? _lng;
  bool _geocodingLoading = false;
  bool _showPrefectureFallback = false;
  String? _selectedPrefecture;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nicknameCtrl = TextEditingController(text: p?.nickname ?? '');
    _birthPlaceCtrl = TextEditingController(text: p?.birthPlace ?? '');
    _gender = p?.gender ?? '未回答';
    _birthDate = p?.birthDate;
    if (p?.birthTime != null) {
      _birthTime =
          TimeOfDay(hour: p!.birthTime!.hour, minute: p.birthTime!.minute);
    }
    _birthTimeUnknown = p?.birthTime == null && p != null;
    _lat = p?.birthLat;
    _lng = p?.birthLng;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _birthPlaceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _birthTime = picked);
  }

  Future<void> _resolveLocation() async {
    final place = _birthPlaceCtrl.text.trim();
    if (place.isEmpty) return;
    setState(() {
      _geocodingLoading = true;
      _showPrefectureFallback = false;
    });
    try {
      final locations = await locationFromAddress(place);
      if (locations.isNotEmpty) {
        setState(() {
          _lat = locations.first.latitude;
          _lng = locations.first.longitude;
          _geocodingLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('位置情報を取得しました')),
          );
        }
      } else {
        setState(() {
          _geocodingLoading = false;
          _showPrefectureFallback = true;
        });
      }
    } catch (_) {
      setState(() {
        _geocodingLoading = false;
        _showPrefectureFallback = true;
      });
    }
  }

  void _onPrefectureSelected(String? prefecture) {
    if (prefecture == null) return;
    final coords = _prefectureCoords[prefecture];
    if (coords == null) return;
    setState(() {
      _selectedPrefecture = prefecture;
      _lat = coords.$1;
      _lng = coords.$2;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('生年月日を入力してください')));
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('出生地の位置情報を確認してください')));
      return;
    }

    DateTime? birthTimeDateTime;
    if (!_birthTimeUnknown && _birthTime != null) {
      birthTimeDateTime = DateTime(
        _birthDate!.year,
        _birthDate!.month,
        _birthDate!.day,
        _birthTime!.hour,
        _birthTime!.minute,
      );
    }

    final now = DateTime.now();
    final profile = Profile(
      id: widget.initialProfile?.id ?? 0,
      nickname: _nicknameCtrl.text.trim(),
      gender: _gender,
      birthDate: _birthDate!,
      birthTime: birthTimeDateTime,
      birthPlace: _birthPlaceCtrl.text.trim(),
      birthLat: _lat!,
      birthLng: _lng!,
      createdAt: widget.initialProfile?.createdAt ?? now,
      updatedAt: now,
    );
    widget.onSave(profile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy年M月d日');

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nicknameCtrl,
            decoration: const InputDecoration(labelText: 'ニックネーム *'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'ニックネームを入力してください' : null,
          ),
          const SizedBox(height: 20),
          Text('性別', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: _genderOptions
                .map((g) => ButtonSegment(value: g, label: Text(g)))
                .toList(),
            selected: {_gender},
            onSelectionChanged: (s) => setState(() => _gender = s.first),
            style: ButtonStyle(
              textStyle: WidgetStatePropertyAll(theme.textTheme.labelSmall),
            ),
          ),
          const SizedBox(height: 20),
          Text('生年月日 *', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    _birthDate != null
                        ? dateFormat.format(_birthDate!)
                        : '選択してください',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _birthDate != null
                          ? null
                          : theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('出生時刻', style: theme.textTheme.labelMedium),
              Row(
                children: [
                  Text('不明', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Switch(
                    value: _birthTimeUnknown,
                    onChanged: (v) =>
                        setState(() => _birthTimeUnknown = v),
                  ),
                ],
              ),
            ],
          ),
          if (!_birthTimeUnknown) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_outlined,
                        size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      _birthTime != null
                          ? _birthTime!.format(context)
                          : '選択してください',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _birthTime != null
                            ? null
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          TextFormField(
            controller: _birthPlaceCtrl,
            decoration: InputDecoration(
              labelText: '出生地 *',
              hintText: '例: 東京都新宿区',
              suffixIcon: _geocodingLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      tooltip: '位置を確認',
                      onPressed: _resolveLocation,
                    ),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '出生地を入力してください' : null,
          ),
          if (_lat != null && _lng != null) ...[
            const SizedBox(height: 8),
            Text(
              '位置: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
          if (_showPrefectureFallback) ...[
            const SizedBox(height: 12),
            Text('位置の特定に失敗しました。都道府県を選択してください:',
                style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedPrefecture,
              hint: const Text('都道府県を選択'),
              items: _prefectureCoords.keys
                  .map((p) =>
                      DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: _onPrefectureSelected,
              decoration: const InputDecoration(labelText: '都道府県'),
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: widget.isSaving ? null : _submit,
            child: widget.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('保存する'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
