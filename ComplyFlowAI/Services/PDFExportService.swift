import Foundation
import UIKit

struct ReportSection: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var body: String
}

struct ReportContent: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var businessName: String
    var sections: [ReportSection]
    var photoData: [Data]
    var createdAt: Date = .now

    var disclaimer: String {
        ComplianceConstants.disclaimerText
    }
}

struct PDFExportService {
    func generatePDF(for report: ReportContent) throws -> URL {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let margin: CGFloat = 48
        let contentWidth = pageRect.width - margin * 2
        let fileName = sanitizedFileName(report.title) + ".pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        try renderer.writePDF(to: url) { context in
            var y = margin
            context.beginPage()
            y = draw("ComplyFlow AI", font: .systemFont(ofSize: 14, weight: .semibold), color: .systemBlue, x: margin, y: y, width: contentWidth, spacing: 8)
            y = draw(report.title, font: .systemFont(ofSize: 28, weight: .bold), color: .label, x: margin, y: y, width: contentWidth, spacing: 6)
            y = draw(report.subtitle, font: .systemFont(ofSize: 13, weight: .regular), color: .secondaryLabel, x: margin, y: y, width: contentWidth, spacing: 16)
            y = draw("Business: \(report.businessName.isEmpty ? "Not specified" : report.businessName)", font: .systemFont(ofSize: 12, weight: .medium), color: .label, x: margin, y: y, width: contentWidth, spacing: 20)

            for section in report.sections {
                if y > pageRect.height - 140 {
                    context.beginPage()
                    y = margin
                }
                y = draw(section.title, font: .systemFont(ofSize: 16, weight: .semibold), color: .label, x: margin, y: y, width: contentWidth, spacing: 6)
                y = draw(section.body, font: .systemFont(ofSize: 12, weight: .regular), color: .label, x: margin, y: y, width: contentWidth, spacing: 16)
            }

            if !report.photoData.isEmpty {
                if y > pageRect.height - 220 {
                    context.beginPage()
                    y = margin
                }
                y = draw("Photos", font: .systemFont(ofSize: 16, weight: .semibold), color: .label, x: margin, y: y, width: contentWidth, spacing: 10)
                for data in report.photoData.prefix(4) {
                    guard let image = UIImage(data: data) else { continue }
                    if y > pageRect.height - 180 {
                        context.beginPage()
                        y = margin
                    }
                    let imageRect = aspectFitRect(for: image.size, inside: CGRect(x: margin, y: y, width: 220, height: 150))
                    image.draw(in: imageRect)
                    y = imageRect.maxY + 16
                }
            }

            if y > pageRect.height - 120 {
                context.beginPage()
                y = margin
            }
            _ = draw("Disclaimer", font: .systemFont(ofSize: 13, weight: .semibold), color: .label, x: margin, y: y, width: contentWidth, spacing: 4)
            _ = draw(report.disclaimer, font: .systemFont(ofSize: 10, weight: .regular), color: .secondaryLabel, x: margin, y: y + 20, width: contentWidth, spacing: 0)
        }

        return url
    }

    private func draw(_ text: String, font: UIFont, color: UIColor, x: CGFloat, y: CGFloat, width: CGFloat, spacing: CGFloat) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        let rect = NSString(string: text).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        NSString(string: text).draw(
            with: CGRect(x: x, y: y, width: width, height: ceil(rect.height)),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        return y + ceil(rect.height) + spacing
    }

    private func sanitizedFileName(_ value: String) -> String {
        let cleaned = value.replacingOccurrences(of: "[^A-Za-z0-9-]+", with: "-", options: .regularExpression)
        return cleaned.trimmingCharacters(in: CharacterSet(charactersIn: "-")).isEmpty ? "ComplyFlow-Report" : cleaned
    }

    private func aspectFitRect(for size: CGSize, inside rect: CGRect) -> CGRect {
        guard size.width > 0, size.height > 0 else { return rect }
        let scale = min(rect.width / size.width, rect.height / size.height)
        let width = size.width * scale
        let height = size.height * scale
        return CGRect(x: rect.minX, y: rect.minY, width: width, height: height)
    }
}
