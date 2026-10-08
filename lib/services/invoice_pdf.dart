import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/booking_model.dart';

/// Builds and shares booking invoices as PDF documents.
///
/// Requirements honoured here:
///  * all text is clean, plain English (built-in Helvetica fonts),
///  * money is always written as "BDT 15,000.00" — never a currency glyph.
class InvoicePdf {
  InvoicePdf._();

  static final DateFormat _dateFmt = DateFormat('d MMMM yyyy');

  /// BDT 15,000.00 — grouped thousands, two decimals, explicit currency.
  static String formatBdt(double amount) {
    final negative = amount < 0;
    final fixed = amount.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    final digits = parts[0];
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '${negative ? '-' : ''}BDT $buffer.${parts[1]}';
  }

  static String invoiceNumber(Booking booking) =>
      'CG-INV-${booking.id.toString().padLeft(6, '0')}';

  static String _statusLabel(BookingStatus status) => switch (status) {
    BookingStatus.pending => 'Pending confirmation',
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.completed => 'Completed',
    BookingStatus.cancelled => 'Cancelled',
  };

  static String _typeLabel(BookingType type) => switch (type) {
    BookingType.hotel => 'Hotel booking',
    BookingType.transport => 'Transport booking',
    BookingType.guide => 'Guide booking',
    BookingType.destination => 'Tour package',
  };

  /// Renders the invoice and returns the raw PDF bytes.
  static Future<Uint8List> build(Booking booking) async {
    final doc = pw.Document();
    final green = PdfColor.fromHex('#1B7A4F');
    final darkGreen = PdfColor.fromHex('#135E3B');
    final ink = PdfColor.fromHex('#16181A');
    final grey = PdfColor.fromHex('#5F6368');
    final hair = PdfColor.fromHex('#E1EAE2');
    final soft = PdfColor.fromHex('#E4F4EA');

    pw.Widget row(String label, String value, {bool strong = false}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    color: grey,
                    fontWeight: strong ? pw.FontWeight.bold : null,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 3,
                child: pw.Text(
                  value,
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    color: ink,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(44),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── Letterhead ──────────────────────────────────────────
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ComfyGo',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: green,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Travel Agency · Bangladesh',
                        style: pw.TextStyle(fontSize: 10, color: grey),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: ink,
                        letterSpacing: 2,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'No. ${invoiceNumber(booking)}',
                      style: pw.TextStyle(fontSize: 10.5, color: grey),
                    ),
                    pw.Text(
                      'Issued on ${_dateFmt.format(booking.createdAt)}',
                      style: pw.TextStyle(fontSize: 10.5, color: grey),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: green, thickness: 1.6),
            pw.SizedBox(height: 16),

            // ── Billed to ──────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: soft,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Billed to',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: darkGreen,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    booking.touristName.isEmpty
                        ? 'Valued customer'
                        : booking.touristName,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: ink,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Booking reference: #${booking.id}',
                    style: pw.TextStyle(fontSize: 10.5, color: grey),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // ── Booking details ────────────────────────────────────
            pw.Text(
              'Booking details',
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: ink,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Divider(color: hair, thickness: 1),
            row('Item', booking.itemName),
            row('Service', _typeLabel(booking.type)),
            row('Check-in', _dateFmt.format(booking.checkIn)),
            if (booking.checkOut != null)
              row('Check-out', _dateFmt.format(booking.checkOut!)),
            row('Guests / seats', '${booking.guests}'),
            row('Status', _statusLabel(booking.status)),
            if (booking.notes != null && booking.notes!.isNotEmpty)
              row('Notes', booking.notes!),
            pw.Divider(color: hair, thickness: 1),
            pw.SizedBox(height: 14),

            // ── Amount due ─────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: green,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Total amount',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Includes all service charges',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Text(
                    formatBdt(booking.totalPrice),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.Spacer(),

            // ── Footer ─────────────────────────────────────────────
            pw.Divider(color: hair, thickness: 1),
            pw.SizedBox(height: 8),
            pw.Text(
              'This is a computer-generated invoice and does not require a '
              'signature.',
              style: pw.TextStyle(fontSize: 9, color: grey),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'Thank you for travelling with ComfyGo. '
              'Support: support@comfygo.com · +880 1700-000000',
              style: pw.TextStyle(fontSize: 9, color: grey),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// Builds the invoice and opens the share sheet (download / send).
  static Future<void> share(Booking booking) async {
    final bytes = await build(booking);
    final file = XFile.fromData(
      bytes,
      mimeType: 'application/pdf',
      name: 'Invoice_${invoiceNumber(booking)}.pdf',
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        subject: 'Invoice ${invoiceNumber(booking)}',
        text:
            'Invoice ${invoiceNumber(booking)} for your ComfyGo booking '
            '${formatBdt(booking.totalPrice)}.',
      ),
    );
  }
}
