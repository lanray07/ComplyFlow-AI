import SwiftUI

struct CardSurface<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            )
    }
}

struct SeverityBadge: View {
    let severity: Severity

    init(_ severity: Severity) {
        self.severity = severity
    }

    init(rawValue: String) {
        self.severity = Severity(rawValue: rawValue) ?? .low
    }

    var body: some View {
        Text(severity.rawValue)
            .font(.caption.weight(.semibold))
            .foregroundStyle(severity.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(severity.tint.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityLabel("Severity \(severity.rawValue)")
    }
}

struct UpgradeBanner: View {
    let title: String
    let message: String
    let action: () -> Void

    var body: some View {
        CardSurface {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Upgrade", action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct ComplianceDisclaimerView: View {
    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 10) {
                Label("Review required", systemImage: "exclamationmark.shield")
                    .font(.headline)
                    .foregroundStyle(.orange)
                ForEach(ComplianceConstants.disclaimerBullets, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.blue)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

struct VoiceNoteButton: View {
    @Binding var text: String
    @StateObject private var speech = SpeechRecognitionService()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                if speech.isRecording {
                    let captured = speech.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                    speech.stop()
                    if !captured.isEmpty {
                        if !text.isEmpty { text += "\n" }
                        text += captured
                    }
                } else {
                    Task { await speech.start() }
                }
            } label: {
                Label(speech.isRecording ? "Stop dictation" : "Voice note", systemImage: speech.isRecording ? "stop.circle.fill" : "mic.circle")
            }
            .buttonStyle(.bordered)

            if speech.isRecording, !speech.transcript.isEmpty {
                Text(speech.transcript)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let errorMessage = speech.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
    }
}

struct InspectionCard: View {
    let inspection: Inspection

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(inspection.title)
                            .font(.headline)
                        Text("\(inspection.type) - \(inspection.location)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    SeverityBadge(rawValue: inspection.severity)
                }
                HStack {
                    Label(inspection.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    Spacer()
                    Label("\(inspection.failedItems.count) failed", systemImage: "xmark.octagon")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

struct SOPCard: View {
    let sop: SOPDocument

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 8) {
                Text(sop.title)
                    .font(.headline)
                Text(sop.task)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Label(sop.createdAt.formatted(date: .abbreviated, time: .omitted), systemImage: "doc.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct IncidentCard: View {
    let incident: IncidentReport

    var body: some View {
        CardSurface {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(incident.title)
                            .font(.headline)
                        Text("\(incident.type) - \(incident.location)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    SeverityBadge(rawValue: incident.severity)
                }
                Text(incident.incidentDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}

struct AuditCard: View {
    let audit: AuditReport

    var body: some View {
        CardSurface {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(.blue.opacity(0.18), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: CGFloat(audit.score) / 100)
                        .stroke(.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(audit.score)")
                        .font(.headline)
                }
                .frame(width: 58, height: 58)
                VStack(alignment: .leading, spacing: 4) {
                    Text(audit.auditType)
                        .font(.headline)
                    Text("\(audit.findings.count) findings, \(audit.highRiskGaps.count) high-risk gaps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }
}

struct ReminderCard: View {
    let reminder: ReminderItem

    var isOverdue: Bool {
        !reminder.completed && reminder.dueDate < Calendar.current.startOfDay(for: .now)
    }

    var body: some View {
        CardSurface {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: reminder.completed ? "checkmark.circle.fill" : isOverdue ? "exclamationmark.circle.fill" : "bell.circle")
                    .foregroundStyle(reminder.completed ? .green : isOverdue ? .red : .blue)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.title)
                        .font(.headline)
                    Text(reminder.category)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(reminder.dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(isOverdue ? .red : .secondary)
                }
                Spacer()
            }
        }
    }
}

extension Severity {
    var tint: Color {
        switch self {
        case .low:
            .green
        case .medium:
            .yellow
        case .high:
            .orange
        case .critical:
            .red
        }
    }
}

extension View {
    func complyFlowScreenBackground() -> some View {
        background(Color(.systemGroupedBackground))
    }
}

