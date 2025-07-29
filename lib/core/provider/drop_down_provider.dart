// Provides the DropdownService instance
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/provider/auth_provider.dart';
import 'package:learn_riverpod/core/service/dropdown_service.dart';

final dropdownServiceProvider = Provider<DropdownService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DropdownService(client);
});
