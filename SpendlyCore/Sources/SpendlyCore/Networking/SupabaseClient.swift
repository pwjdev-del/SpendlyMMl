import Foundation
import Supabase

public class SpendlySupabase {
    public static let shared = SpendlySupabase()
    public let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://ocgscikxbnetmipxpjvq.supabase.co")!,
            supabaseKey: "sb_publishable_izbM_YpSxEwhkSs-cYgZaQ_KrY8zNy_"
        )
    }
}
