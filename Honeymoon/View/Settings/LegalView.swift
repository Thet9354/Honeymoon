//
//  LegalView.swift
//  Honeymoon
//

import SwiftUI

enum LegalDocument {
    case privacyPolicy
    case termsOfService

    var title: String {
        switch self {
        case .privacyPolicy:  "Privacy Policy"
        case .termsOfService: "Terms of Service"
        }
    }

    /// Date the current policy text took effect. Update this string whenever
    /// the policy body below changes.
    static let effectiveDate = "26 June 2026"

    static let contactEmail = "thetpine254@gmail.com"

    var body: String {
        switch self {
        case .privacyPolicy:  Self.privacyPolicyText
        case .termsOfService: Self.termsOfServiceText
        }
    }

    private static let privacyPolicyText =
        """
        Last updated: \(effectiveDate)

        This Privacy Policy explains how Honeymoon ("the app") handles your \
        information. The app is provided by Thet Pine ("we", "us"). By creating \
        an account or using the app, you agree to the practices described here.

        1. INFORMATION WE COLLECT

        Account information. When you sign up or sign in, we collect the email \
        address associated with your account and a unique account identifier. \
        If you sign in with Google or Apple, we receive your email address and, \
        where you allow it, your name. If you use Sign in with Apple and choose \
        to hide your email, we receive Apple's private relay address instead of \
        your personal email.

        Content you create. We store the destinations you save as favorites and \
        the destinations you mark with "Book Destination". This information is \
        tied to your account so it is available when you sign in again.

        We do not collect your precise location or your contacts, and the app \
        does not contain third-party advertising, analytics, or tracking \
        software. If you buy Honeymoon Premium, the purchase is processed by \
        Apple through your App Store account; we receive confirmation that the \
        purchase is active but never see or store your card or payment details.

        2. HOW WE USE YOUR INFORMATION

        We use your information only to operate the app: to authenticate you, \
        to keep you signed in, and to save and sync your favorites and booking \
        list across your sessions and devices. We do not sell your personal \
        information and we do not use it for advertising.

        3. THIRD-PARTY SERVICES

        The app uses Google Firebase (Firebase Authentication and Cloud \
        Firestore) to manage accounts and store your data. Firebase is operated \
        by Google LLC, which processes this data on our behalf. When you sign in \
        with Google or Apple, those companies process your sign-in according to \
        their own privacy policies. We encourage you to review the Google \
        Privacy Policy and the Apple Privacy Policy. In-app purchases are \
        handled by Apple's App Store, which processes payment under Apple's own \
        privacy policy.

        4. WHERE YOUR DATA IS STORED

        Your account profile and saved content are stored in Google Firestore \
        servers located in the Asia–Southeast region. Data in transit is \
        encrypted using industry-standard protocols. While no method of \
        transmission or storage is completely secure, we rely on Firebase's \
        security infrastructure to protect your information.

        5. DATA RETENTION AND DELETION

        We keep your information for as long as your account exists. You can \
        delete your account at any time from Settings → Delete Account. Deleting \
        your account permanently removes your profile and your saved favorites \
        and bookings from our records. This action cannot be undone.

        6. CHILDREN'S PRIVACY

        The app is not directed to children under 13, and we do not knowingly \
        collect personal information from children. If you believe a child has \
        provided us information, please contact us so we can remove it.

        7. YOUR RIGHTS

        You may access and update your saved content within the app, and you may \
        delete your account and associated data at any time as described above. \
        For any other request relating to your personal information, contact us \
        using the details below.

        8. CHANGES TO THIS POLICY

        We may update this Privacy Policy from time to time. When we do, we will \
        revise the "Last updated" date above. Continued use of the app after a \
        change means you accept the updated policy.

        9. CONTACT US

        If you have any questions about this Privacy Policy, contact us at \
        \(contactEmail).
        """

    private static let termsOfServiceText =
        """
        Last updated: \(effectiveDate)

        These Terms of Service ("Terms") govern your use of the Honeymoon app \
        ("the app"), provided by Thet Pine ("we", "us"). By using the app, you \
        agree to these Terms. If you do not agree, please do not use the app.

        1. ELIGIBILITY

        You must be at least 13 years old to use the app. By using it, you \
        confirm that you meet this requirement and that any information you \
        provide is accurate.

        2. YOUR ACCOUNT

        You are responsible for keeping your sign-in credentials secure and for \
        all activity that occurs under your account. Notify us promptly if you \
        believe your account has been used without your permission.

        3. THE SERVICE

        The app lets you browse honeymoon destinations, save them as favorites, \
        and add them to a personal "booking" list. The "Book Destination" \
        feature is for organising your own wish list only. It does not book or \
        pay for any travel, lodging, or related services, and does not create \
        any obligation by us or any third party to provide them. Destination \
        information is provided for general inspiration and may not be accurate, \
        current, or available.

        4. PURCHASES AND SUBSCRIPTIONS

        The app is free to use. An optional "Honeymoon Premium" upgrade unlocks \
        additional features such as full day-by-day itineraries. Premium is \
        offered as either a one-time "Lifetime" purchase or an auto-renewing \
        "Annual" subscription, which may include a free trial. Prices are shown \
        in the app before you confirm a purchase.

        Payment is charged to your Apple ID account when you confirm. An annual \
        subscription renews automatically for the same period at the \
        then-current price unless you cancel at least 24 hours before the end of \
        the current period; any unused portion of a free trial is forfeited when \
        you buy a subscription. You can manage or cancel a subscription, and view \
        its renewal date, in your Apple ID account settings, and you can restore \
        a previous purchase from the upgrade screen. Purchases are processed by \
        Apple and are subject to the App Store Terms of Sale; refunds are handled \
        by Apple in accordance with those terms.

        5. ACCEPTABLE USE

        You agree to use the app only for lawful, personal, non-commercial \
        purposes. You agree not to misuse the app, interfere with its operation, \
        attempt to access other users' data, or use it in any way that violates \
        applicable law.

        6. CONTENT AND INTELLECTUAL PROPERTY

        The app, including its design, text, and imagery, is protected by \
        intellectual property rights and may not be copied or redistributed \
        without permission. The content you save remains associated with your \
        account and is handled as described in our Privacy Policy.

        7. DISCLAIMER OF WARRANTIES

        The app is provided "as is" and "as available", without warranties of \
        any kind, whether express or implied. We do not warrant that the app \
        will be uninterrupted, error-free, or that any destination information \
        is accurate or reliable.

        8. LIMITATION OF LIABILITY

        To the maximum extent permitted by law, we will not be liable for any \
        indirect, incidental, or consequential damages arising from your use of, \
        or inability to use, the app, including any reliance on destination \
        information or the "booking" feature.

        9. TERMINATION

        You may stop using the app and delete your account at any time. We may \
        suspend or terminate access if you violate these Terms or misuse the app.

        10. GOVERNING LAW

        These Terms are governed by the laws of Singapore, without regard to its \
        conflict-of-law rules. Any disputes arising from these Terms or your use \
        of the app are subject to the jurisdiction of the courts of Singapore.

        11. CHANGES TO THESE TERMS

        We may update these Terms from time to time. When we do, we will revise \
        the "Last updated" date above. Continued use of the app after a change \
        means you accept the updated Terms.

        12. CONTACT US

        If you have any questions about these Terms, contact us at \(contactEmail).
        """
}

struct LegalView: View {

    let document: LegalDocument

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(document.body)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LegalView(document: .privacyPolicy)
    }
}
