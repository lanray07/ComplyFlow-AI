import Foundation

enum ComplianceConstants {
    static let internalAIPrompt = """
    You are ComplyFlow AI, an operational compliance assistant for businesses. Review inspection notes, incident reports, SOP requests, audit details, and uploaded evidence. Generate structured operational compliance outputs using cautious and professional language. Do not provide legal advice, certification guarantees, regulatory approval, or safety certification. Recommend review by qualified professionals where appropriate.
    """

    static let disclaimerBullets = [
        "Not legal advice",
        "Not regulatory certification",
        "AI suggestions must be reviewed",
        "Not a replacement for licensed professionals",
        "Users remain responsible for operational compliance"
    ]

    static let disclaimerText = "ComplyFlow AI provides operational drafting and organization support only. It is not legal advice, regulatory certification, safety certification, or a replacement for licensed compliance, legal, safety, or trade professionals. AI suggestions must be reviewed before use. Users remain responsible for operational compliance."

    static let aiPrivacyText = "This App Store build uses local mock AI only. Inspection notes, photos, incident reports, SOP requests, audit details, business profile details, and reminders are not sent to OpenAI, ChatGPT, or any other third-party AI service."

    static let termsOfUseURL = URL(string: "https://github.com/lanray07/ComplyFlow-AI/blob/main/docs/terms.md")!
    static let privacyPolicyURL = URL(string: "https://github.com/lanray07/ComplyFlow-AI/blob/main/docs/privacy.md")!
}
