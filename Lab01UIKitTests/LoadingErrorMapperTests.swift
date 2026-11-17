import Foundation
import Testing
@testable import Lab01UIKit

struct LoadingErrorMapperTests {

    @Test func offlineErrorGetsWifiIcon() {
        let info = LoadingErrorMapper.map(URLError(.notConnectedToInternet))
        #expect(info.iconName == "wifi.slash")
        #expect(info.message.contains(L10n.Loading.offline))
    }

    @Test func timeoutGetsClockIcon() {
        #expect(LoadingErrorMapper.iconName(for: URLError(.timedOut)) == "clock.badge.exclamationmark")
    }

    @Test func decodingErrorGetsDocumentIcon() {
        let error = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))
        #expect(LoadingErrorMapper.iconName(for: error) == "doc.text.magnifyingglass")
    }

    @Test func unknownErrorFallsBackToWarning() {
        #expect(LoadingErrorMapper.iconName(for: NetworkError.invalidResponse) == "exclamationmark.triangle")
    }
}
