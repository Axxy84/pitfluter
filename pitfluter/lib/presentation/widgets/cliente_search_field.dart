import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/cliente.dart';

class ClienteSearchField extends StatefulWidget {
  final Function(Cliente) onClienteSelected;
  final Future<List<Cliente>> Function(String) searchClientes;
  final String? hintText;
  final Duration debounceDuration;

  const ClienteSearchField({
    super.key,
    required this.onClienteSelected,
    required this.searchClientes,
    this.hintText = 'Buscar cliente...',
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ClienteSearchField> createState() => _ClienteSearchFieldState();
}

class _ClienteSearchFieldState extends State<ClienteSearchField> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<Cliente> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    
    if (query.isEmpty) {
      _clearSuggestions();
      return;
    }

    _debounceTimer = Timer(widget.debounceDuration, () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await widget.searchClientes(query);
      
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
        _showSuggestions();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
        _showSuggestions();
      }
    }
  }

  void _showSuggestions() {
    _removeOverlay();
    
    if (_suggestions.isEmpty && !_isLoading) {
      _overlayEntry = _createOverlayEntry(isEmptyState: true);
    } else {
      _overlayEntry = _createOverlayEntry();
    }
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry({bool isEmptyState = false}) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : isEmptyState
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Nenhum cliente encontrado',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final cliente = _suggestions[index];
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(
                                cliente.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                cliente.telefone,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              onTap: () {
                                _controller.text = cliente.nome;
                                widget.onClienteSelected(cliente);
                                _clearSuggestions();
                              },
                            );
                          },
                        ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearSuggestions() {
    _removeOverlay();
    setState(() {
      _suggestions = [];
      _isLoading = false;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Semantics(
        label: 'Campo de busca de clientes',
        child: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      _clearSuggestions();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}