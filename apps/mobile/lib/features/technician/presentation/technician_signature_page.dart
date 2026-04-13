import 'package:flutter/material.dart';
import '../../../core/design/app_design.dart';

class TechnicianSignaturePage extends StatefulWidget {
  const TechnicianSignaturePage({super.key, required this.workOrderId});
  final String workOrderId;

  @override
  State<TechnicianSignaturePage> createState() => _TechnicianSignaturePageState();
}

class _TechnicianSignaturePageState extends State<TechnicianSignaturePage> {
  final List<Offset?> _points = [];
  final GlobalKey _signatureKey = GlobalKey();
  bool _isDrawing = false;

  void _clear() {
    setState(() => _points.clear());
  }

  void _save() {
    if (_points.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen teslimat için imza atınız.')),
      );
      return;
    }

    // Mock save and close
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Icon(Icons.check_circle_rounded, color: AppColors.statusGreen, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'İş Tamamlandı!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('${widget.workOrderId} numaralı cihazın teslimat imzası alındı ve iş bitirildi.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to home
            },
            child: const Text('TAMAM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LinearPageShell(
      title: 'Teslimat Onayı',
      subtitle: 'Müşteri İmzası',
      showBack: true,
      tabBar: const SizedBox.shrink(),
      scrollPhysics: _isDrawing ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      children: [
        // ── Customer Info & Agreement ────────────────────────────────
        const SizedBox(height: 20),
        const Text(
          'MÜŞTERİ BEYANI',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: const Text(
            'Cihazımı tam çalışır durumda ve eksiksiz olarak teslim aldım. Teknik servis hizmetinden memnun kaldığımı ve işlemi onayladığımı beyan ederim.',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.5),
          ),
        ),

        const SizedBox(height: 24),

        // ── Signature Board (White Canvas) ───────────────────────────
        const Text(
          'DİJİTAL İMZA',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const SizedBox(height: 12),
        Container(
          height: 500,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Listener(
              onPointerDown: (event) {
                final box = _signatureKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  Offset localPos = box.globalToLocal(event.position);
                  if (localPos.dx >= 0 && localPos.dy >= 0 && localPos.dx <= box.size.width && localPos.dy <= box.size.height) {
                    setState(() {
                      _isDrawing = true;
                      _points.add(localPos);
                    });
                  }
                }
              },
              onPointerMove: (event) {
                final box = _signatureKey.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) {
                  Offset localPos = box.globalToLocal(event.position);
                  setState(() => _points.add(localPos));
                }
              },
              onPointerUp: (event) {
                setState(() {
                  _isDrawing = false;
                  _points.add(null);
                });
              },
              child: Container(
                key: _signatureKey,
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: CustomPaint(
                  painter: SignaturePainter(points: _points),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // ── Actions ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clear,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
                ),
                child: const Text('TEMİZLE', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xs)),
                ),
                child: const Text('İMZALAT VE BİTİR', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true; // Always repaint when points change
}
