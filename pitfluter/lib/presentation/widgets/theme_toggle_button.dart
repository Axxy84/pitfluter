import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final bool isIconOnly;
  
  const ThemeToggleButton({
    super.key,
    this.isIconOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (isIconOnly) {
          return IconButton(
            icon: Icon(
              themeProvider.isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            tooltip: themeProvider.isDarkMode 
                ? 'Modo Claro' 
                : 'Modo Escuro',
            onPressed: () => themeProvider.toggleTheme(),
          );
        } else {
          return ListTile(
            leading: Icon(
              themeProvider.isDarkMode 
                  ? Icons.light_mode 
                  : Icons.dark_mode,
            ),
            title: Text(
              themeProvider.isDarkMode 
                  ? 'Modo Claro' 
                  : 'Modo Escuro'
            ),
            onTap: () => themeProvider.toggleTheme(),
          );
        }
      },
    );
  }
}