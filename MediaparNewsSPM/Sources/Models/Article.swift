//
//  Article.swift
//  
//
//  Created by 19172093 on 11.01.2022.
//

import Foundation

// MARK: - Article
public struct Article: Codable, Equatable, Hashable, Identifiable {
	public var id = UUID()
	public let title, articleDescription: String
	public let content: String
	public let url: String
	public let image: String
	public let publishedAt: String
	public let source: Source

	public enum CodingKeys: String, CodingKey {
		case title
		case articleDescription = "description"
		case content, url, image, publishedAt, source
	}
}

extension Article {


	static public var mock: Article = .init(
		title: "Μετά τη μετάλλαξη Όμικρον, θα πρέπει να μάθουμε να ζούμε με τον κορωνοϊό",
		articleDescription: "Προάγγελος μετάβασης σε μία νέα, λιγότερο επικίνδυνη «ενδημική» φάση της πανδημίας αποτελεί κατά πολλούς επιστήμονες η παρούσα «έκρηξη» των κρουσμάτων του κορωνοϊού λόγω της παραλλαγής Όμικρον . Όμως, οι επόμενες εβδομάδες για την Ευρώπη θα είναι",
		content: "Ειδήσεις - Προάγγελος μετάβασης σε μία νέα, λιγότερο επικίνδυνη «ενδημική» φάση της πανδημίας αποτελεί κατά πολλούς επιστήμονες η παρούσα «έκρηξη» των κρουσμάτων του...",
		url: "https://www.cnn.gr/kosmos/story/296673/meta-ti-metallaxi-omikron-tha-prepei-na-mathoyme-na-zoyme-me-ton-koronoio",
		image: "https://cdn.cnngreece.gr/media/news/2022/01/08/296673/facebook/facebookcovid-italia-milano-omokron-26262402315_n.jpg", publishedAt: "",
		source: Source.mockCnn
	)

	static public var mock1: Article = .init(
		title: "天文學家發現一條橫跨銀河系巨型雲帶",
		articleDescription: "天文學家發現銀河系內一條巨大的氫氣雲帶，是銀河系內迄今發現的最大天體結構之一。雖然現在它只是一條氫氣雲，但是科學家認為這可能是一個未來將誕生新星的地方。銀河系內的天體結構跨度達到800光年已經算巨大了，新發現的這條氫氣雲帶長達3900多光年，寬達130光年。研究人員給它起名「麥琪」（Maggie），認為它很可能是...",
		content: "天文學家發現一條橫跨銀河系巨型雲帶\n上半部為銀河系的側視圖，暗黑部份為星際氣體和塵埃遮擋星光而成，右側較明亮的部份為銀河系中心，其左側旋臂的一部份放大為下半部的圖像，其中發現一條長達3900多光年的氫氣雲帶（如虛線所示）。（ESA/Gaia/DPAC, CC BY-SA 3.0 IGO & T. Muller/J. Syed/MPIA）\n天文學家發現銀河系內一條巨大的氫氣雲帶，是銀河系內迄今發現的最大天體結構之一。雖然現在它只是一條氫氣雲，但是科學家認為這可能是一個未來將誕生新星的地方。\n銀河系... [980 chars]",
		url: "https://hk.epochtimes.com/news/2022-01-09/78174234",
		image: "https://i.epochtimes.com/assets/uploads/2022/01/id13489796-filament.png", publishedAt: "2022-01-09T06:41:19Z",
		source: Source.mockChinese
	)

	static public var mock2: Article = .init(
		title: "Japanskt drama kritikerfavorit inför Oscarsgala",
		articleDescription: "Det japanska dramat \"Drive my car\" seglar upp som en kritikerfavorit inför Oscarsgalan. Redan nu har tre amerikanska kritikerorganisationer utsett den till årets bästa film.",
		content: "På lördagen var det National Society of Film Critics som gav sitt finaste pris till Ryusuke Hamaguchis film, i konkurrens med Celine Sciammas \"Lilla mamma\" och Jane Campions \"The power of the dog\", uppger The Wrap. Hamaguchi tilldelades också priset",
		url: "https://nyheter24.se/noje/kultur/982332-japanskt-drama-kritikerfavorit-infor-oscarsgala",
		image: "https://cdn03.nyheter24.se/275ca0e704df010a010000410000047902/2022/01/09/1725442/tt_image4knCWi.jpeg",
		publishedAt: "2022-01-09T06:40:03Z",
		source: Source.mockSwidesh
	)
}
