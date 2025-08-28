import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutx/flutx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../utils/CustomTheme.dart';
import '../../../../utils/Utilities.dart';
import '../../models/Product.dart';

class PricesEntryScreen extends StatefulWidget {
  final List<PriceModel> selected;

  PricesEntryScreen({Key? key, required this.selected}) : super(key: key);

  @override
  State<PricesEntryScreen> createState() => _PricesEntryScreenState();
}

class _PricesEntryScreenState extends State<PricesEntryScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  /// The minimum quantity (automatically determined)
  int min_qty = 1;

  /// Adds a new price entry to the list
  void _addPrice() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formValues = _formKey.currentState!.value;
      setState(() {
        widget.selected.add(
          PriceModel()
            ..min_qty = Utils.int_parse(
              formValues['min_qty']?.toString() ?? '0',
            )
            ..max_qty = Utils.int_parse(
              formValues['max_qty']?.toString() ?? '0',
            )
            ..price = formValues['price']?.toString() ?? '',
        );
      });
      // Recalculate new min_qty based on all entries.
      _recalculateMinQty();
      _formKey.currentState?.reset();
      _formKey.currentState!.patchValue({'min_qty': min_qty.toString()});
    }
  }

  /// Recalculates the minimum quantity based on the maximum quantities of all entries.
  void _recalculateMinQty() {
    if (widget.selected.isEmpty) {
      min_qty = 1;
    } else {
      int newMin = 1;
      for (var entry in widget.selected) {
        if (entry.max_qty >= newMin) {
          newMin = entry.max_qty + 1;
        }
      }
      min_qty = newMin;
    }
  }

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely patch the initial value.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMinQty();
    });
  }

  void _initializeMinQty() {
    if (widget.selected.isNotEmpty) {
      _recalculateMinQty();
    }
    _formKey.currentState?.patchValue({'min_qty': min_qty.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter Prices"),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 35),
            onPressed: () {
              // Return the list of price entries when done.
              Navigator.pop(context, widget.selected);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade300,
            padding: FxSpacing.xy(16, 8),
            child: FormBuilder(
              key: _formKey,
              child: Row(
                children: [
                  // "From (QTY)" field – read-only and automatically set.
                  Expanded(
                    flex: 1,
                    child: FormBuilderTextField(
                      name: 'min_qty',
                      initialValue: min_qty.toString(),
                      readOnly: true,
                      decoration: CustomTheme.input_decoration(
                        labelText: 'From (QTY)',
                        isDense: true,
                        label_font_size: 8,
                        padding: FxSpacing.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  FxSpacing.width(5),
                  // "To (QTY)" field – must be greater than [min_qty]
                  Expanded(
                    flex: 1,
                    child: FormBuilderTextField(
                      name: 'max_qty',
                      decoration: CustomTheme.input_decoration(
                        labelText: 'To (QTY)',
                        isDense: true,
                        label_font_size: 8,
                        padding: FxSpacing.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Required'),
                        FormBuilderValidators.min(
                          min_qty + 1,
                          errorText: 'Must be greater than $min_qty',
                        ),
                      ]),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  FxSpacing.width(16),
                  // "Price" field – required
                  Expanded(
                    flex: 1,
                    child: FormBuilderTextField(
                      name: 'price',
                      decoration: CustomTheme.input_decoration(
                        labelText: 'Price',
                        isDense: true,
                        padding: FxSpacing.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                      ),
                      validator: FormBuilderValidators.required(
                        errorText: 'Required',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  FxSpacing.width(16),
                  // "Add Price" button
                  Expanded(
                    flex: 1,
                    child: FxButton(
                      onPressed: _addPrice,
                      borderRadiusAll: 4,
                      padding: FxSpacing.xy(0, 0),
                      splashColor: FxAppTheme.theme.colorScheme.primary,
                      elevation: 0,
                      child: FxText.labelLarge(
                        "ADD PRICE",
                        color: FxAppTheme.theme.colorScheme.onPrimary,
                        fontWeight: 800,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List displaying the current price entries.
          Expanded(
            child: ListView.separated(
              itemCount: widget.selected.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final entry = widget.selected[index];
                return ListTile(
                  title: FxText.titleLarge('Price: ${entry.price}'),
                  subtitle: Text('Qty: ${entry.min_qty} - ${entry.max_qty}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        widget.selected.removeAt(index);
                        _recalculateMinQty();
                        _formKey.currentState?.patchValue({
                          'min_qty': min_qty.toString(),
                        });
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
