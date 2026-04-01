import 'package:flutter/material.dart';

import '../network_monitor_service.dart';
import '../network_request_record.dart';
import 'network_request_tile.dart';

class NetworkDomainGroup extends StatefulWidget {
  final String domain;
  final List<NetworkRequestRecord> records;
  final Color borderColor;
  final Color textMain;
  final Color textMuted;
  final Color accent;

  const NetworkDomainGroup({
    super.key,
    required this.domain,
    required this.records,
    required this.borderColor,
    required this.textMain,
    required this.textMuted,
    required this.accent,
  });

  @override
  State<NetworkDomainGroup> createState() => _NetworkDomainGroupState();
}

class _NetworkDomainGroupState extends State<NetworkDomainGroup> {
  bool _expanded = false;

  int get _totalBytes => widget.records.fold(0, (sum, r) => sum + r.totalBytes);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: widget.borderColor.withValues(alpha: 0.2),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: widget.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.domain,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14, color: widget.textMain)),
                ),
                Text('${widget.records.length} req',
                    style: TextStyle(fontSize: 12, color: widget.textMuted)),
                const SizedBox(width: 12),
                Text(NetworkMonitorService.formatBytes(_totalBytes),
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12, color: widget.accent)),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.records.map((r) => NetworkRequestTile(
                record: r,
                borderColor: widget.borderColor,
                textMain: widget.textMain,
                textMuted: widget.textMuted,
              )),
      ],
    );
  }
}
