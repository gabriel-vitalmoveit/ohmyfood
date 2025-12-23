import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../services/providers/api_providers.dart';

class AddressFormScreen extends HookConsumerWidget {
  const AddressFormScreen({this.addressId, super.key});

  final String? addressId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelController = useTextEditingController();
    final streetController = useTextEditingController();
    final numberController = useTextEditingController();
    final complementController = useTextEditingController();
    final postalCodeController = useTextEditingController();
    final cityController = useTextEditingController();
    final instructionsController = useTextEditingController();
    final isDefault = useState(false);
    final isLoading = useState(false);

    // Se editando, carregar dados
    useEffect(() {
      if (addressId != null) {
        final apiClient = ref.read(apiClientProvider);
        apiClient.getAddresses().then((addresses) {
          final address = addresses.firstWhere((a) => a['id'] == addressId);
          labelController.text = address['label'] ?? '';
          streetController.text = address['street'] ?? '';
          numberController.text = address['number'] ?? '';
          complementController.text = address['complement'] ?? '';
          postalCodeController.text = address['postalCode'] ?? '';
          cityController.text = address['city'] ?? '';
          instructionsController.text = address['instructions'] ?? '';
          isDefault.value = address['isDefault'] == true;
        });
      }
      return null;
    }, [addressId]);

    Future<void> save() async {
      if (labelController.text.isEmpty ||
          streetController.text.isEmpty ||
          numberController.text.isEmpty ||
          postalCodeController.text.isEmpty ||
          cityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
        );
        return;
      }

      isLoading.value = true;
      try {
        final apiClient = ref.read(apiClientProvider);
        final addressData = {
          'label': labelController.text.trim(),
          'street': streetController.text.trim(),
          'number': numberController.text.trim(),
          'complement': complementController.text.trim().isEmpty ? null : complementController.text.trim(),
          'postalCode': postalCodeController.text.trim(),
          'city': cityController.text.trim(),
          'instructions': instructionsController.text.trim().isEmpty ? null : instructionsController.text.trim(),
          'isDefault': isDefault.value,
        };

        if (addressId != null) {
          await apiClient.updateAddress(addressId!, addressData);
        } else {
          await apiClient.createAddress(addressData);
        }

        if (context.mounted) {
          context.pop(true);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: ${e.toString()}')),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(addressId != null ? 'Editar morada' : 'Nova morada'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(OhMyFoodSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Etiqueta *',
                hintText: 'Casa, Trabalho, etc.',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            TextField(
              controller: streetController,
              decoration: const InputDecoration(
                labelText: 'Rua *',
                hintText: 'Rua da República',
                prefixIcon: Icon(Icons.streetview),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: numberController,
                    decoration: const InputDecoration(
                      labelText: 'Número *',
                      hintText: '123',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                ),
                const SizedBox(width: OhMyFoodSpacing.md),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: complementController,
                    decoration: const InputDecoration(
                      labelText: 'Complemento',
                      hintText: 'Apto 4B',
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Código Postal *',
                      hintText: '1000-001',
                      prefixIcon: Icon(Icons.markunread_mailbox),
                    ),
                  ),
                ),
                const SizedBox(width: OhMyFoodSpacing.md),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: cityController,
                    decoration: const InputDecoration(
                      labelText: 'Cidade *',
                      hintText: 'Lisboa',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: OhMyFoodSpacing.md),
            TextField(
              controller: instructionsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Instruções de entrega',
                hintText: 'Campainha: OHMYFOOD, 3º esquerdo',
                prefixIcon: Icon(Icons.note_outlined),
              ),
            ),
            const SizedBox(height: OhMyFoodSpacing.lg),
            SwitchListTile(
              title: const Text('Morada padrão'),
              subtitle: const Text('Usar esta morada por padrão'),
              value: isDefault.value,
              onChanged: (value) => isDefault.value = value,
            ),
            const SizedBox(height: OhMyFoodSpacing.xl),
            ElevatedButton(
              onPressed: isLoading.value ? null : save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: OhMyFoodSpacing.md),
              ),
              child: isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(addressId != null ? 'Guardar' : 'Criar morada'),
            ),
          ],
        ),
      ),
    );
  }
}

