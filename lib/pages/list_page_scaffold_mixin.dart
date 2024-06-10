part of 'list_page_scaffold.dart';

mixin _ListPageScaffoldMixin on ConsumerState<ListPageScaffold> {

  final ValueNotifier<bool> _excelExportingNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _deleteProcessingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _excelExportingNotifier.value = false;
    _deleteProcessingNotifier.value = false;
  }

  Future<void> onDelete() async {
    _deleteProcessingNotifier.value = true;
    try {
    if (ref.read(widget.selectionProvider).selectedItems.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (final BuildContext context) {
          return DeletionDialog(
              type: widget.type, companyName: widget.companyName, selectionProvider: widget.selectionProvider);
        },
      );
    } else {
      Toast(
        context,
        text: "No ${widget.type.name} selected for deletion!",
        color: Colors.redAccent,
      );
    }
  } catch (e) {
    Toast(
      context,
      text: "An error occurred while deleting ${widget.type.name}!\n$e",
      color: Colors.redAccent,
    );
  }
    _deleteProcessingNotifier.value = false;
  }

  Future<void> onExcelOutput() async {
    _excelExportingNotifier.value = true;
    final String text = widget.type == ListType.invoice ? "${widget.companyName!}'s ${ref.read(widget.selectionProvider).selectedItems[widget.companyName]!.length}" : ref.read(widget.selectionProvider).selectedItems.keys.length.toString();
    try {
      if ((widget.type == ListType.invoice && ref.read(widget.selectionProvider).selectedItems[widget.companyName]!.isNotEmpty) ||
          (widget.type != ListType.invoice && ref.read(widget.selectionProvider).selectedItems.isNotEmpty)) {
        await exportToExcel(listType: widget.type,
            companyName: widget.companyName,
            outputList: ref
                .read(widget.selectionProvider)
                .selectedItems);
        Toast(context,
            text:
            "$text ${widget.type.name}(s) lists saved as excel output in "
                "Download"
                " file.",
            color: Colors.green);
      } else {
        Toast(
          context,
          text: "No ${widget.type.name}(s) selected to Excel output!",
          color: Colors.redAccent,
        );
      }

    } catch (e) {
      Toast(context,
          text: e.toString(), color: Colors.redAccent);
    } finally {
      _excelExportingNotifier.value = false;
    }
}

}
