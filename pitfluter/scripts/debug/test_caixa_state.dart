// ignore_for_file: avoid_print, unused_import, unused_local_variable, prefer_const_constructors
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qmnwhqgqzijnyxfxgmaw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFtbndhcWdxemlqbnl4ZnhnbWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUzODY0MzUsImV4cCI6MjA1MDk2MjQzNX0.4CfwpX_2LNaVeFPPRv7oReMsPI9QiD69KkmwZmq8XxI',
  );

  final supabase = Supabase.instance.client;

  try {
    // Check current cash register state
    // DEBUG: Checking cash register state
    
    final response = await supabase
        .from('caixa')
        .select()
        .order('data_abertura', ascending: false)
        .limit(1);
    
    if (response.isEmpty) {
      // DEBUG: No cash register records found - caixa is CLOSED
    } else {
      final ultimoCaixa = response.first;
      final bool aberto = ultimoCaixa['data_fechamento'] == null;
      
      // DEBUG: Last cash register record:
      // DEBUG:   ID: ${ultimoCaixa['id']}
      // DEBUG:   Open date: ${ultimoCaixa['data_abertura']}
      // DEBUG:   Close date: ${ultimoCaixa['data_fechamento']}
      // DEBUG:   Status: ${aberto ? 'OPEN' : 'CLOSED'}
      
      if (aberto) {
        // DEBUG: Cash register is currently OPEN - dialog should NOT appear
      } else {
        // DEBUG: Cash register is currently CLOSED - dialog SHOULD appear
      }
    }
  } catch (e) {
    // DEBUG: Error checking cash register: $e
  }
}