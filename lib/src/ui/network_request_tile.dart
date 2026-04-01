import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network_monitor_service.dart';
import '../network_request_record.dart';

class NetworkRequestTile extends StatefulWidget {
  final NetworkRequestRecord record;
  final Color borderColor;
  final Color textMain;
  final Color textMuted;

  const NetworkRequestTile({
    super.key,
    required this.record,
    required this.borderColor,
    required this.textMain,
    required this.textMuted,
  });

  @override
  State<NetworkRequestTile> createState() => _NetworkRequestTileState();
}

class _NetworkRequestTileState extends State<NetworkRequestTile> {
  bool _expanded = false;

  Color get _statusColor {
    final code = widget.record.statusCode;
    if (code == 0) return Colors.grey;
    if (code < 300) return Colors.green;
    if (code < 400) return Colors.orange;
    return Colors.red;
  }

  Color get _methodColor {
    switch (widget.record.method.toUpperCase()) {
      case 'GET':
        return const Color(0xff61AFFE);
      case 'POST':
        return const Color(0xff49CC90);
      case 'PUT':
        return const Color(0xffFCA130);
      case 'PATCH':
        return const Color(0xff50E3C2);
      case 'DELETE':
        return const Color(0xffF93E3E);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: widget.borderColor, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(record),
            if (_expanded) ...[
              const SizedBox(height: 8),
              _buildDetails(record),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NetworkRequestRecord record) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _methodColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(record.method,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: _methodColor)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            record.path.isEmpty ? record.url : record.path,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: widget.textMain),
          ),
        ),
        const SizedBox(width: 8),
        Text('${record.statusCode}',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: _statusColor)),
        const SizedBox(width: 6),
        Text(NetworkMonitorService.formatBytes(record.totalBytes),
            style: TextStyle(fontSize: 10, color: widget.textMuted)),
        const SizedBox(width: 6),
        Text(
            '${record.timestamp.hour.toString().padLeft(2, '0')}:'
            '${record.timestamp.minute.toString().padLeft(2, '0')}:'
            '${record.timestamp.second.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 9, color: widget.textMuted.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildDetails(NetworkRequestRecord record) {
    final labelStyle =
        TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: widget.textMain);
    final valueStyle = TextStyle(fontSize: 12, color: widget.textMuted);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: widget.borderColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _copyableRow('URL', record.url, labelStyle, valueStyle),
          const SizedBox(height: 4),
          _row('Domain', record.domain, labelStyle, valueStyle),
          const SizedBox(height: 4),
          _row('Status', '${record.statusCode}', labelStyle, valueStyle),
          const SizedBox(height: 4),
          _row('Request Size', NetworkMonitorService.formatBytes(record.requestSizeBytes),
              labelStyle, valueStyle),
          const SizedBox(height: 4),
          _row('Response Size', NetworkMonitorService.formatBytes(record.responseSizeBytes),
              labelStyle, valueStyle),
          const SizedBox(height: 4),
          _row('Duration', '${record.duration.inMilliseconds} ms', labelStyle, valueStyle),
          const SizedBox(height: 4),
          _row('Source', record.source, labelStyle, valueStyle),
          const SizedBox(height: 4),
          _row(
              'Time',
              '${record.timestamp.hour.toString().padLeft(2, '0')}:'
                  '${record.timestamp.minute.toString().padLeft(2, '0')}:'
                  '${record.timestamp.second.toString().padLeft(2, '0')}',
              labelStyle,
              valueStyle),
        ],
      ),
    );
  }

  Widget _row(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: labelStyle)),
        Expanded(
            child: Text(value, style: valueStyle, maxLines: 3, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _copyableRow(String label, String value, TextStyle labelStyle, TextStyle valueStyle) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URL copied', style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface)),
            backgroundColor: Theme.of(context).colorScheme.inverseSurface,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: labelStyle)),
          Expanded(
            child: Text(value, style: valueStyle.copyWith(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
            )),
          ),
          Icon(Icons.copy, size: 14, color: widget.textMuted),
        ],
      ),
    );
  }
}
