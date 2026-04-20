import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/generated/app_localizations.dart';
import 'package:smart_agri_app/local/pref_helper.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  final ValueNotifier<bool> isDarkNotifier;
  const AdminUsersScreen({super.key, required this.isDarkNotifier});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final Dio _dio = Dio();
  List<dynamic> _users = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<Options> _authOptions() async {
    final token = await PrefHelper.getToken();
    return Options(headers: {'Authorization': 'Bearer $token', 'ngrok-skip-browser-warning': 'true'});
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      final opts = await _authOptions();
      final response = await _dio.get('${Config.baseUrl}/users', options: opts);
      if (!mounted) return;
      setState(() {
        _users = response.data['data'] ?? [];
        _filtered = _users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Failed to load users'; _loading = false; });
    }
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = _users.where((u) =>
        (u['username'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
        (u['name'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
        (u['email'] ?? '').toLowerCase().contains(query.toLowerCase()) ||
        (u['role'] ?? '').toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  Future<void> _deleteUser(dynamic user, bool isDark, AppLocalizations l) async {
    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final errorColor = isDark ? AppColors.error : AppColorsLight.error;
    final bg = isDark ? AppColors.background : AppColorsLight.background;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: border)),
        title: Text(l.deleteUser, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
        content: Text('${l.confirmDeleteUser} "${user['username']}"?', style: TextStyle(color: textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel, style: TextStyle(color: textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: errorColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l.delete, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final opts = await _authOptions();
        await _dio.delete('${Config.baseUrl}/users/${user['id']}', options: opts);
        _loadUsers();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.userDeleted), backgroundColor: primary));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showUserForm(bool isDark, AppLocalizations l, {dynamic user}) {
    final isEdit = user != null;
    final usernameCtrl = TextEditingController(text: user?['username'] ?? '');
    final passwordCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: user?['name'] ?? '');
    final emailCtrl = TextEditingController(text: user?['email'] ?? '');
    final phoneCtrl = TextEditingController(text: user?['phone_no'] ?? '');
    final addressCtrl = TextEditingController(text: user?['address'] ?? '');
    String role = user?['role'] ?? 'customer';

    final surface = isDark ? AppColors.surface : AppColorsLight.surface;
    final surfaceAlt = isDark ? AppColors.surfaceAlt : AppColorsLight.surfaceAlt;
    final border = isDark ? AppColors.border : AppColorsLight.border;
    final primary = isDark ? AppColors.primary : AppColorsLight.primary;
    final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final bg = isDark ? AppColors.background : AppColorsLight.background;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(isEdit ? l.editUser : l.addUser, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: role,
              dropdownColor: surfaceAlt,
              style: TextStyle(color: textPrimary, fontSize: 14),
              decoration: _inputDeco(l.role, textSecondary, surface, border, primary),
              items: [
                DropdownMenuItem(value: 'farmer', child: Text(l.farmer)),
                DropdownMenuItem(value: 'customer', child: Text(l.customer)),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (v) => setModalState(() => role = v!),
            ),
            const SizedBox(height: 12),

            if (!isEdit) ...[
              _textField(usernameCtrl, l.username, Icons.person_outline, textPrimary, textSecondary, surface, border, primary),
              const SizedBox(height: 12),
              _textField(passwordCtrl, l.defaultPassword, Icons.lock_outline, textPrimary, textSecondary, surface, border, primary, obscure: true),
              const SizedBox(height: 12),
            ],

            _textField(nameCtrl, l.fullName, Icons.badge_outlined, textPrimary, textSecondary, surface, border, primary),
            const SizedBox(height: 12),
            _textField(emailCtrl, 'Email', Icons.email_outlined, textPrimary, textSecondary, surface, border, primary, keyboard: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _textField(phoneCtrl, l.phone, Icons.phone_outlined, textPrimary, textSecondary, surface, border, primary, keyboard: TextInputType.phone),
            const SizedBox(height: 12),
            _textField(addressCtrl, l.address, Icons.location_on_outlined, textPrimary, textSecondary, surface, border, primary),

            if (isEdit) ...[
              const SizedBox(height: 12),
              _textField(passwordCtrl, l.newPassword, Icons.lock_outline, textPrimary, textSecondary, surface, border, primary, obscure: true),
            ],

            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(14)),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final opts = await _authOptions();
                    if (isEdit) {
                      await _dio.put(
                        '${Config.baseUrl}/users/${user['id']}',
                        data: {
                          'role': role, 'name': nameCtrl.text, 'email': emailCtrl.text,
                          'phone_no': phoneCtrl.text, 'address': addressCtrl.text,
                          'gender': user['gender'] ?? 'male', 'dob': user['dob'],
                          'farm_name': user['farm_name'], 'farmer_registration_no': user['farmer_registration_no'],
                          if (passwordCtrl.text.isNotEmpty) 'password': passwordCtrl.text,
                        },
                        options: opts,
                      );
                      Navigator.pop(ctx);
                      _loadUsers();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.userUpdated), backgroundColor: primary));
                    } else {
                      if (usernameCtrl.text.isEmpty) return;
                      await _dio.post(
                        '${Config.baseUrl}/users',
                        data: {
                          'username': usernameCtrl.text, 'role': role,
                          'name': nameCtrl.text, 'email': emailCtrl.text,
                          'phone_no': phoneCtrl.text, 'address': addressCtrl.text,
                          'gender': 'male', 'dob': null,
                          if (passwordCtrl.text.isNotEmpty) 'password': passwordCtrl.text,
                        },
                        options: opts,
                      );
                      Navigator.pop(ctx);
                      _loadUsers();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.userCreated), backgroundColor: primary));
                    }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: Text(l.saveChanges, style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 8),
          ])),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, Color textSecondary, Color surface, Color border, Color primary) {
    return InputDecoration(
      labelText: label, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
      filled: true, fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, IconData icon, Color textPrimary, Color textSecondary, Color surface, Color border, Color primary, {bool obscure = false, TextInputType? keyboard}) {
    return TextField(
      controller: ctrl, obscureText: obscure, keyboardType: keyboard,
      style: TextStyle(color: textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: textSecondary, size: 18),
        filled: true, fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primary, width: 1.5)),
      ),
    );
  }

  Color _roleColor(String role, Color primary, Color cyan, Color gold) {
    switch (role) {
      case 'admin': return gold;
      case 'farmer': return primary;
      default: return cyan;
    }
  }

  String _formatDate(dynamic d) {
    if (d == null) return '-';
    try { final dt = DateTime.parse(d.toString()); return '${dt.day}/${dt.month}/${dt.year}'; } catch (_) { return d.toString(); }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDarkNotifier,
      builder: (context, isDark, _) {
        final bg = isDark ? AppColors.background : AppColorsLight.background;
        final surface = isDark ? AppColors.surface : AppColorsLight.surface;
        final border = isDark ? AppColors.border : AppColorsLight.border;
        final primary = isDark ? AppColors.primary : AppColorsLight.primary;
        final cyan = isDark ? AppColors.cyan : AppColorsLight.cyan;
        final gold = isDark ? AppColors.gold : AppColorsLight.gold;
        final textPrimary = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
        final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
        final errorColor = isDark ? AppColors.error : AppColorsLight.error;

        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: bg,
              title: Text(l.userManagement, style: TextStyle(color: textPrimary)),
              iconTheme: IconThemeData(color: textPrimary),
              actions: [
                IconButton(icon: Icon(Icons.refresh, color: textSecondary, size: 20), onPressed: _loadUsers),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: border)),
            ),
            body: Column(children: [
              // Search
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearch,
                  style: TextStyle(color: textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l.searchUsers,
                    hintStyle: TextStyle(color: textSecondary, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(icon: Icon(Icons.clear, color: textSecondary, size: 18), onPressed: () { _searchCtrl.clear(); _onSearch(''); })
                        : null,
                    filled: true, fillColor: surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primary, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),

              // Stats
              if (!_loading && _error == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(children: [
                    _statChip(l.total, _users.length.toString(), textSecondary, surface, border),
                    const SizedBox(width: 8),
                    _statChip('Admin', _users.where((u) => u['role'] == 'admin').length.toString(), gold, surface, border),
                    const SizedBox(width: 8),
                    _statChip(l.farmer, _users.where((u) => u['role'] == 'farmer').length.toString(), primary, surface, border),
                    const SizedBox(width: 8),
                    _statChip(l.customer, _users.where((u) => u['role'] == 'customer').length.toString(), cyan, surface, border),
                  ]),
                ),

              const SizedBox(height: 12),

              // List
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: primary))
                    : _error != null
                        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.error_outline, color: textSecondary, size: 48),
                            const SizedBox(height: 12),
                            Text(_error!, style: TextStyle(color: textSecondary)),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _loadUsers, style: ElevatedButton.styleFrom(backgroundColor: primary), child: Text(l.retry, style: TextStyle(color: bg))),
                          ]))
                        : _filtered.isEmpty
                            ? Center(child: Text(l.noUsersFound, style: TextStyle(color: textSecondary)))
                            : RefreshIndicator(
                                onRefresh: _loadUsers, color: primary,
                                child: ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                  itemCount: _filtered.length,
                                  itemBuilder: (context, index) {
                                    final user = _filtered[index];
                                    final roleColor = _roleColor(user['role'] ?? '', primary, cyan, gold);
                                    final initials = (user['name'] ?? user['username'] ?? 'U')[0].toUpperCase();
                                    final roleLabel = user['role'] == 'farmer' ? l.farmer : user['role'] == 'customer' ? l.customer : 'Admin';

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                                      child: Row(children: [
                                        Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(color: roleColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                          child: Center(child: Text(initials, style: TextStyle(color: roleColor, fontWeight: FontWeight.w800, fontSize: 18))),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Column(crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                                          Row(
                                            mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
                                            children: [
                                              Text(user['username'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(color: roleColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                                                child: Text(roleLabel.toUpperCase(), style: TextStyle(fontSize: 10, color: roleColor, fontWeight: FontWeight.w700)),
                                              ),
                                            ],
                                          ),
                                          if (user['name'] != null) Text(user['name'], style: TextStyle(fontSize: 12, color: textSecondary)),
                                          if (user['email'] != null) Row(
                                            mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
                                            children: [
                                              Icon(Icons.email_outlined, size: 11, color: textSecondary),
                                              const SizedBox(width: 4),
                                              Flexible(child: Text(user['email'], style: TextStyle(fontSize: 11, color: textSecondary), overflow: TextOverflow.ellipsis)),
                                            ],
                                          ),
                                          Text('${l.registeredOn} ${_formatDate(user['created_at'])}', style: TextStyle(fontSize: 10, color: textSecondary.withOpacity(0.6))),
                                        ])),

                                        PopupMenuButton<String>(
                                          color: isDark ? AppColors.surfaceAlt : AppColorsLight.surfaceAlt,
                                          icon: Icon(Icons.more_vert, color: textSecondary, size: 20),
                                          onSelected: (val) {
                                            if (val == 'edit') _showUserForm(isDark, l, user: user);
                                            if (val == 'delete') _deleteUser(user, isDark, l);
                                          },
                                          itemBuilder: (_) => [
                                            PopupMenuItem(value: 'edit', child: Row(children: [
                                              Icon(Icons.edit_outlined, color: primary, size: 16),
                                              const SizedBox(width: 8),
                                              Text(l.edit ?? 'Edit', style: TextStyle(color: textPrimary, fontSize: 13)),
                                            ])),
                                            PopupMenuItem(value: 'delete', child: Row(children: [
                                              Icon(Icons.delete_outline, color: errorColor, size: 16),
                                              const SizedBox(width: 8),
                                              Text(l.delete, style: TextStyle(color: errorColor, fontSize: 13)),
                                            ])),
                                          ],
                                        ),
                                      ]),
                                    );
                                  },
                                ),
                              ),
              ),
            ]),
            floatingActionButton: Container(
              decoration: BoxDecoration(gradient: LinearGradient(colors: [primary, cyan]), borderRadius: BorderRadius.circular(16)),
              child: FloatingActionButton.extended(
                onPressed: () => _showUserForm(isDark, l),
                backgroundColor: Colors.transparent, elevation: 0,
                icon: Icon(Icons.person_add_outlined, color: bg),
                label: Text(l.addUser, style: TextStyle(color: bg, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statChip(String label, String value, Color color, Color surface, Color border) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
      Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
    ]),
  );
}