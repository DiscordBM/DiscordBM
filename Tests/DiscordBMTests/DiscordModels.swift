@testable import DiscordModels
import DiscordHTTP
import NIOCore
import XCTest

class DiscordModelsTests: XCTestCase {
    
    func testEventDecode() throws {
        
        do {
            let text = """
            {
                "t": null,
                "s": null,
                "op": 11,
                "d": null
            }
            """
            let decoded = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
            XCTAssertEqual(decoded.opcode, .heartbeatAccepted)
            XCTAssertEqual(decoded.sequenceNumber, nil)
            XCTAssertEqual(decoded.type, nil)
            XCTAssertTrue(decoded.data == nil)
        }
        
        do {
            let text = """
            {
            "t": "MESSAGE_CREATE",
            "s": 130,
            "op": 0,
            "d": {
                "type": 0,
                "tts": false,
                "timestamp": "2022-10-07T19:44:07.295000+00:00",
                "referenced_message": null,
                "pinned": false,
                "nonce": "1028029979960541184",
                "mentions": [],
                "mention_roles": [],
                "mention_everyone": false,
                "member": {
                    "roles": [
                        "431921695524126722"
                    ],
                    "premium_since": null,
                    "pending": false,
                    "nick": null,
                    "mute": false,
                    "joined_at": "2020-04-18T00:10:04.414000+00:00",
                    "flags": 0,
                    "deaf": false,
                    "communication_disabled_until": null,
                    "avatar": null
                },
                "id": "1028029980795478046",
                "flags": 0,
                "embeds": [],
                "edited_timestamp": null,
                "content": "blah bljhshADh blah",
                "components": [],
                "channel_id": "435923868503506954",
                "author": {
                    "username": "GoodUser",
                    "public_flags": 0,
                    "id": "560661188019488714",
                    "discriminator": "4443",
                    "avatar_decoration": null,
                    "avatar": "845407ec1491b55828cc1f91c2436e8b"
                },
                "attachments": [],
                "guild_id": "439103874612675485"
                }
            }
            """
            let decoded = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
            XCTAssertEqual(decoded.opcode, .dispatch)
            XCTAssertEqual(decoded.sequenceNumber, 130)
            XCTAssertEqual(decoded.type, "MESSAGE_CREATE")
            guard case let .messageCreate(message) = decoded.data else {
                XCTFail("Unexpected data: \(String(describing: decoded.data))")
                return
            }
            XCTAssertEqual(message.type, .default)
            XCTAssertEqual(message.tts, false)
            XCTAssertEqual(message.timestamp.date.timeIntervalSince1970, 1665171847.295)
            XCTAssertTrue(message.referenced_message == nil)
            XCTAssertEqual(message.pinned, false)
            XCTAssertEqual(message.nonce?.asString, "1028029979960541184")
            XCTAssertTrue(message.mentions.isEmpty)
            XCTAssertEqual(message.mention_roles, [])
            XCTAssertEqual(message.mention_everyone, false)
            let member = try XCTUnwrap(message.member)
            XCTAssertEqual(member.roles, ["431921695524126722"])
            XCTAssertEqual(member.premium_since?.date, nil)
            XCTAssertEqual(member.pending, false)
            XCTAssertEqual(member.nick, nil)
            XCTAssertEqual(member.mute, false)
            XCTAssertEqual(member.joined_at?.date.timeIntervalSince1970, 1587168604.414)
            XCTAssertEqual(member.deaf, false)
            XCTAssertEqual(member.communication_disabled_until?.date, nil)
            XCTAssertEqual(member.avatar, nil)
            XCTAssertEqual(message.id, "1028029980795478046")
            XCTAssertEqual(message.flags, [])
            XCTAssertTrue(message.embeds.isEmpty)
            XCTAssertEqual(message.edited_timestamp?.date, nil)
            XCTAssertEqual(message.content, "blah bljhshADh blah")
            XCTAssertTrue(message.components?.isEmpty == true)
            XCTAssertEqual(message.channel_id, "435923868503506954")
            let author = try XCTUnwrap(message.author)
            XCTAssertEqual(author.username, "GoodUser")
            XCTAssertEqual(author.public_flags, [])
            XCTAssertEqual(author.id, "560661188019488714")
            XCTAssertEqual(author.discriminator, "4443")
            XCTAssertEqual(author.avatar_decoration, nil)
            XCTAssertEqual(author.avatar, "845407ec1491b55828cc1f91c2436e8b")
            XCTAssertTrue(message.attachments.isEmpty)
            XCTAssertEqual(message.guild_id, "439103874612675485")
        }
        
        do {
            let text = """
            {
                "t": "GUILD_AUDIT_LOG_ENTRY_CREATE",
                "s": 1806139,
                "op": 0,
                "d": {
                    "user_id": "159985870458322944",
                    "target_id": "981723329457164289",
                    "id": "1063214083664511006",
                    "changes": [
                        {
                            "old_value": "Online Members: 24",
                            "new_value": "Online Members: 25",
                            "key": "name"
                        }
                    ],
                    "action_type": 11,
                    "guild_id": "964554609010040873"
                }
            }
            """
            let decoded = try JSONDecoder().decode(Gateway.Event.self, from: Data(text.utf8))
            XCTAssertEqual(decoded.opcode, .dispatch)
            XCTAssertEqual(decoded.sequenceNumber, 1806139)
            XCTAssertEqual(decoded.type, "GUILD_AUDIT_LOG_ENTRY_CREATE")
            guard case let .guildAuditLogEntryCreate(auditLog) = decoded.data else {
                XCTFail("Unexpected data: \(String(describing: decoded.data))")
                return
            }
            XCTAssertEqual(auditLog.changes?.count, 1)
            XCTAssertEqual(auditLog.user_id, "159985870458322944")
            XCTAssertEqual(auditLog.id, "1063214083664511006")
            if case .channelUpdate = auditLog.action { } else {
                XCTFail("Unexpected action: \(String(describing: auditLog.action))")
            }
            XCTAssertEqual(auditLog.reason, nil)
        }
    }
    
    func testImageData() throws {
        typealias ImageData = RequestBody.ImageData
        let data = ByteBuffer(data: resource(name: "1kb.png"))
        
        do {
            let image = ImageData(file: .init(data: data, filename: "1kb.png"))
            let string = image.encodeToString()
            XCTAssertEqual(string, base64EncodedImageString)
        }
        
        do {
            let file = ImageData.decodeFromString(base64EncodedImageString)
            XCTAssertEqual(file?.data, data)
            XCTAssertEqual(file?.extension, "png")
        }
    }
    
    func testWebhookAddress() throws {
        let webhookUrl = "https://discord.com/api/webhooks/1066287437724266536/dSmCyqTEGP1lBnpWJAVU-CgQy4s3GRXpzKIeHs0ApHm62FngQZPn7kgaOyaiZe6E5wl_"
        let expectedId = "1066287437724266536"
        let expectedToken = "dSmCyqTEGP1lBnpWJAVU-CgQy4s3GRXpzKIeHs0ApHm62FngQZPn7kgaOyaiZe6E5wl_"
        
        let address1 = try WebhookAddress.url(webhookUrl)
        XCTAssertEqual(address1.id, expectedId)
        XCTAssertEqual(address1.token, expectedToken)
        
        let address2 = try WebhookAddress.url(webhookUrl + "/")
        XCTAssertEqual(address2.id, expectedId)
        XCTAssertEqual(address2.token, expectedToken)
    }
    
    func testReaction() throws {
        XCTAssertNoThrow(try Reaction.unicodeEmoji("❤️"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("✅"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🇮🇷"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("❌"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🆔"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("📲"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🛳️"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🧂"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("🌫️"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("👌🏿"))
        XCTAssertNoThrow(try Reaction.unicodeEmoji("😀"))
        XCTAssertThrowsError(try Reaction.unicodeEmoji("😀a"))
        XCTAssertThrowsError(try Reaction.unicodeEmoji("😀😀"))
    }
    
    func testJSONErrorDecoding() throws {
        let json = """
        {
        "message": "Invalid authentication token",
        "code": 50014
        }
        """
        let data = ByteBuffer(string: json)
        let response = DiscordHTTPResponse(
            host: "discord.com",
            status: .unauthorized,
            version: .http1_1,
            body: data
        )
        let error =  try XCTUnwrap(response.decodeErrorIfUnsuccessful())
        XCTAssertEqual(error.message, "Invalid authentication token")
        XCTAssertEqual(error.code, .invalidAuthenticationToken)
    }
}

private let base64EncodedImageString = #"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABEAAAAOCAMAAAD+MweGAAADAFBMVEUAAAAAAFUAAKoAAP8AJAAAJFUAJKoAJP8ASQAASVUASaoASf8AbQAAbVUAbaoAbf8AkgAAklUAkqoAkv8AtgAAtlUAtqoAtv8A2wAA21UA26oA2/8A/wAA/1UA/6oA//8kAAAkAFUkAKokAP8kJAAkJFUkJKokJP8kSQAkSVUkSaokSf8kbQAkbVUkbaokbf8kkgAkklUkkqokkv8ktgAktlUktqoktv8k2wAk21Uk26ok2/8k/wAk/1Uk/6ok//9JAABJAFVJAKpJAP9JJABJJFVJJKpJJP9JSQBJSVVJSapJSf9JbQBJbVVJbapJbf9JkgBJklVJkqpJkv9JtgBJtlVJtqpJtv9J2wBJ21VJ26pJ2/9J/wBJ/1VJ/6pJ//9tAABtAFVtAKptAP9tJABtJFVtJKptJP9tSQBtSVVtSaptSf9tbQBtbVVtbaptbf9tkgBtklVtkqptkv9ttgBttlVttqpttv9t2wBt21Vt26pt2/9t/wBt/1Vt/6pt//+SAACSAFWSAKqSAP+SJACSJFWSJKqSJP+SSQCSSVWSSaqSSf+SbQCSbVWSbaqSbf+SkgCSklWSkqqSkv+StgCStlWStqqStv+S2wCS21WS26qS2/+S/wCS/1WS/6qS//+2AAC2AFW2AKq2AP+2JAC2JFW2JKq2JP+2SQC2SVW2Saq2Sf+2bQC2bVW2baq2bf+2kgC2klW2kqq2kv+2tgC2tlW2tqq2tv+22wC221W226q22/+2/wC2/1W2/6q2///bAADbAFXbAKrbAP/bJADbJFXbJKrbJP/bSQDbSVXbSarbSf/bbQDbbVXbbarbbf/bkgDbklXbkqrbkv/btgDbtlXbtqrbtv/b2wDb21Xb26rb2//b/wDb/1Xb/6rb////AAD/AFX/AKr/AP//JAD/JFX/JKr/JP//SQD/SVX/Sar/Sf//bQD/bVX/bar/bf//kgD/klX/kqr/kv//tgD/tlX/tqr/tv//2wD/21X/26r/2////wD//1X//6r////qm24uAAAA1ElEQVR42h1PMW4CQQwc73mlFJGCQChFIp0Rh0RBGV5AFUXKC/KPfCFdqryEgoJ8IX0KEF64q0PPnow3jT2WxzNj+gAgAGfvvDdCQIHoSnGYcGDE2nH92DoRqTYJ2bTcsKgqhIi47VdgAWNmwFSFA1UAAT2sSFcnq8a3x/zkkJrhaHT3N+hD3aH7ZuabGHX7bsSMhxwTJLr3evf1e0nBVcwmqcTZuatKoJaB7dSHjTZdM0G1HBTWefly//q2EB7/BEvk5vmzeQaJ7/xKPImpzv8/s4grhAxHl0DsqGUAAAAASUVORK5CYII="#
