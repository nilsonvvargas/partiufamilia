import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import '../models/contact_model.dart';
import '../services/contact_service.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  final ContactService _service = ContactService();
  late Future<List<ContactItem>> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = _service.getContacts();
    });
  }

  void _showContactModal({ContactItem? itemToEdit}) {
    final isEditing = itemToEdit != null;
    final nameController = TextEditingController(text: itemToEdit?.name ?? '');
    final phoneController = TextEditingController(text: itemToEdit?.phone ?? '');
    final whatsappController = TextEditingController(text: itemToEdit?.whatsapp ?? '');
    final locationController = TextEditingController(text: itemToEdit?.location ?? '');
    final notesController = TextEditingController(text: itemToEdit?.notes ?? '');
    String selectedRole = itemToEdit?.role ?? 'Guia de Lancha';

    final roles = [
      'Guia de Lancha',
      'Bugueiro',
      'Transfer / Motorista',
      'Pousada / Anfitrião',
      'Companheiro de Viagem',
      'Emergência'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: MaceioColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: MaceioColors.turquoisePrimary.withValues(alpha: 0.15),
                          child: Icon(
                            isEditing ? Icons.edit : Icons.person_add,
                            color: MaceioColors.turquoisePrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Editar Contato' : 'Novo Contato da Viagem',
                                style: MaceioTypography.titleLarge,
                              ),
                              Text(
                                isEditing ? 'Atualize as informações do contato' : 'Guia, transfer, anfitrião ou emergência',
                                style: MaceioTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do Contato / Serviço',
                        hintText: 'Ex: Capitão Thiago (Lancha)',
                        prefixIcon: const Icon(Icons.person_outline, color: MaceioColors.turquoisePrimary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: roles.contains(selectedRole) ? selectedRole : roles.first,
                      decoration: InputDecoration(
                        labelText: 'Função / Categoria',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Telefone',
                              hintText: 'Ex: (82) 99999-0000',
                              prefixIcon: const Icon(Icons.phone_outlined, color: MaceioColors.turquoisePrimary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: whatsappController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'WhatsApp',
                              hintText: 'Ex: (82) 99999-0000',
                              prefixIcon: const Icon(Icons.chat_outlined, color: MaceioColors.palmGreen),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Localização / Ponto de Encontro',
                        hintText: 'Ex: Marina de Pajuçara',
                        prefixIcon: const Icon(Icons.place_outlined, color: MaceioColors.turquoisePrimary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Observações / Dicas',
                        hintText: 'Ex: Chamar 30 min antes do embarque',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: MaceioButton(
                        label: isEditing ? 'Salvar Alterações' : 'Salvar Contato',
                        icon: isEditing ? Icons.save : Icons.add_circle_outline,
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final phone = phoneController.text.trim();

                          if (name.isNotEmpty && phone.isNotEmpty) {
                            Navigator.pop(context);
                            if (isEditing) {
                              await _service.updateContact(
                                id: itemToEdit.id,
                                name: name,
                                role: selectedRole,
                                phone: phone,
                                whatsapp: whatsappController.text.trim().isNotEmpty
                                    ? whatsappController.text.trim()
                                    : phone,
                                location: locationController.text.trim(),
                                notes: notesController.text.trim(),
                              );
                            } else {
                              await _service.addContact(
                                name: name,
                                role: selectedRole,
                                phone: phone,
                                whatsapp: whatsappController.text.trim().isNotEmpty
                                    ? whatsappController.text.trim()
                                    : phone,
                                location: locationController.text.trim(),
                                notes: notesController.text.trim(),
                              );
                            }
                            _loadData();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteContact(ContactItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Contato?'),
          content: Text('Deseja realmente remover "${item.name}" da lista de contatos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: MaceioColors.error),
              onPressed: () async {
                Navigator.pop(context);
                await _service.deleteContact(item.id);
                _loadData();
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTrip = TripContext.instance.activeTrip;

    return Scaffold(
      backgroundColor: MaceioColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MaceioColors.turquoiseDark,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Novo Contato', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showContactModal(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            MaceioHeader(
              title: activeTrip != null ? 'Contatos • ${activeTrip.destination}' : 'Contatos da Viagem',
              subtitle: 'Guias, jangadeiros, transfer e emergências',
              badge: 'Suporte & Equipe',
              trailing: IconButton(
                icon: const Icon(Icons.refresh, color: MaceioColors.turquoisePrimary),
                onPressed: _loadData,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<ContactItem>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: MaceioColors.turquoisePrimary));
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.contact_phone, size: 48, color: MaceioColors.error),
                          const SizedBox(height: 8),
                          Text('Erro ao carregar contatos', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          MaceioButton(label: 'Tentar Novamente', onPressed: _loadData),
                        ],
                      ),
                    );
                  }

                  final contacts = snapshot.data ?? [];
                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_off, size: 48, color: MaceioColors.textMuted),
                          const SizedBox(height: 8),
                          Text('Nenhum contato cadastrado ainda.', style: MaceioTypography.titleMedium),
                          const SizedBox(height: 8),
                          MaceioButton(label: 'Adicionar Contato', onPressed: () => _showContactModal()),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final item = contacts[index];
                      final isEmergency = item.role == 'Emergência';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: MaceioCard(
                          border: isEmergency
                              ? Border.all(color: MaceioColors.error.withValues(alpha: 0.5), width: 1.5)
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isEmergency ? MaceioColors.coralLight : MaceioColors.oceanLight,
                                    child: Icon(
                                      _getRoleIcon(item.role),
                                      color: isEmergency ? MaceioColors.error : MaceioColors.turquoiseDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.name, style: MaceioTypography.titleMedium),
                                        const SizedBox(height: 2),
                                        Text(item.role, style: MaceioTypography.caption.copyWith(color: MaceioColors.turquoiseDark, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18, color: MaceioColors.textMuted),
                                    tooltip: 'Copiar Telefone',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: item.phone));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Telefone de ${item.name} copiado!')),
                                      );
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: MaceioColors.textMuted, size: 18),
                                    onSelected: (val) {
                                      if (val == 'edit') {
                                        _showContactModal(itemToEdit: item);
                                      } else if (val == 'delete') {
                                        _confirmDeleteContact(item);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 18, color: MaceioColors.turquoiseDark),
                                            SizedBox(width: 8),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, size: 18, color: MaceioColors.error),
                                            SizedBox(width: 8),
                                            Text('Excluir', style: TextStyle(color: MaceioColors.error)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (item.location.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: MaceioColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(item.location, style: MaceioTypography.caption),
                                  ],
                                ),
                              ],
                              if (item.notes.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(item.notes, style: MaceioTypography.bodyMedium),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: MaceioColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone, size: 16, color: MaceioColors.oceanDeep),
                                          const SizedBox(width: 8),
                                          Text(item.phone, style: MaceioTypography.titleMedium.copyWith(fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Guia de Lancha':
        return Icons.sailing;
      case 'Bugueiro':
        return Icons.directions_car;
      case 'Transfer / Motorista':
        return Icons.airport_shuttle;
      case 'Pousada / Anfitrião':
        return Icons.home_work;
      case 'Emergência':
        return Icons.emergency;
      default:
        return Icons.person;
    }
  }
}
