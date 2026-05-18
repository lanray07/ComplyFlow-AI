import SwiftData
import SwiftUI
import UIKit

struct ReportsCenterView: View {
    @Query(sort: \BusinessProfile.createdAt) private var profiles: [BusinessProfile]
    @Query(sort: \Inspection.createdAt, order: .reverse) private var inspections: [Inspection]
    @Query(sort: \IncidentReport.createdAt, order: .reverse) private var incidents: [IncidentReport]
    @Query(sort: \SOPDocument.createdAt, order: .reverse) private var sops: [SOPDocument]
    @Query(sort: \AuditReport.createdAt, order: .reverse) private var audits: [AuditReport]

    private var business: BusinessProfile? {
        profiles.first
    }

    var body: some View {
        List {
            if inspections.isEmpty && incidents.isEmpty && sops.isEmpty && audits.isEmpty {
                EmptyStateView(title: "No reports available", message: "Saved inspections, incidents, SOPs, and audits are available here for preview and PDF export.", systemImage: "doc.richtext")
                    .listRowBackground(Color.clear)
            }

            reportSection("Inspection reports", items: inspections) { inspection in
                NavigationLink {
                    ReportPreviewView(report: ReportFactory.inspection(inspection, business: business))
                } label: {
                    Label(inspection.title, systemImage: "checklist")
                }
            }

            reportSection("Incident reports", items: incidents) { incident in
                NavigationLink {
                    ReportPreviewView(report: ReportFactory.incident(incident, business: business))
                } label: {
                    Label(incident.title, systemImage: "cross.case")
                }
            }

            reportSection("SOP PDFs", items: sops) { sop in
                NavigationLink {
                    ReportPreviewView(report: ReportFactory.sop(sop, business: business))
                } label: {
                    Label(sop.title, systemImage: "doc.badge.gearshape")
                }
            }

            reportSection("Audit summaries", items: audits) { audit in
                NavigationLink {
                    ReportPreviewView(report: ReportFactory.audit(audit, business: business))
                } label: {
                    Label(audit.auditType, systemImage: "clipboard")
                }
            }
        }
        .navigationTitle("Reports Center")
        .complyFlowScreenBackground()
    }

    @ViewBuilder
    private func reportSection<Data: RandomAccessCollection, Row: View>(_ title: String, items: Data, @ViewBuilder row: @escaping (Data.Element) -> Row) -> some View where Data.Element: Identifiable {
        if !items.isEmpty {
            Section(title) {
                ForEach(items) { item in
                    row(item)
                }
            }
        }
    }
}

struct ReportPreviewView: View {
    @EnvironmentObject private var subscriptions: SubscriptionManager
    let report: ReportContent
    @State private var shareItem: ShareItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CardSurface {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(report.title)
                            .font(.title2.bold())
                        Text(report.subtitle)
                            .foregroundStyle(.secondary)
                        Text(report.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                ForEach(report.sections) { section in
                    DetailListCard(title: section.title, values: [section.body])
                }

                if !report.photoData.isEmpty {
                    CardSurface {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Photos")
                                .font(.headline)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 10) {
                                ForEach(Array(report.photoData.enumerated()), id: \.offset) { _, data in
                                    if let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                }

                ComplianceDisclaimerView()

                if subscriptions.isActive {
                    Button {
                        exportReport()
                    } label: {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    NavigationLink(value: AppRoute.paywall) {
                        CardSurface {
                            HStack {
                                Label("PDF export is a Pro feature", systemImage: "lock")
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("Upgrade")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("Report Preview")
        .complyFlowScreenBackground()
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
    }

    private func exportReport() {
        if let url = try? PDFExportService().generatePDF(for: report) {
            shareItem = ShareItem(url: url)
        }
    }
}
