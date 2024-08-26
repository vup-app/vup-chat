import 'dart:convert';

import 'package:did_plc/did_plc.dart';
import 'package:xrpc/xrpc.dart' as xrpc;

Future<Map<String, dynamic>?> getContentRecord(
    String otherDID, String collection, String? rkey) async {
  final plcClient = PLC();
  final didDoc = await plcClient.findDocument(
    did: otherDID,
  );
  final pds = Uri.parse(didDoc.data.service.first.serviceEndpoint).host;

  final response = await xrpc.query<String>(
    xrpc.NSID.create('atproto.com', 'repo.getRecord'),
    service: pds, // This represents the service URL (pds).
    parameters: {
      'repo': otherDID,
      'collection': collection,
      'rkey': rkey ?? "default",
    },
  );
  if (response.status.equalsByCode(200)) {
    return (jsonDecode(response.data));
  } else {
    return null;
  }
}
