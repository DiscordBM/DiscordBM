
extension Gateway.GuildCreate {
    
    public enum PermissionError: Error {
        case memberNotFound(userId: String, guildId: String)
        case channelNotFound(channelId: String, guildId: String)
    }
    
    /// Whether or not a member has a permission in a guild and channel.
    /// - NOTE: You should request all guild member from gateway before calling this function.
    /// `GatewayManager` has a `requestGuildMembersChunk(payload:)` function, for that.
    /// `DiscordCache` comes with a configuration option to request all guild members for you.
    /// https://discord.com/developers/docs/topics/permissions#permission-overwrites
    public func memberHasPermissions(
        userId: String,
        channelId: String,
        permissions perms: [Permission]
    ) throws -> Bool {
        let channel = try self.requireChannel(channelId: channelId)
        let member = try self.requireMember(userId: userId)
        
        /// Guild owner has all permissions.
        if self.owner_id == userId { return true }
        
        /// `administrator` perm is like the guild owner.
        if self.roles.contains(where: { role in
            role.permissions.values.contains(.administrator) &&
            self.memberHasRole(member: member, roleId: role.id)
        }) {
            return true
        }
        
        func hasPerm(_ perm: Permission) -> Bool {
            _memberHasPermission(
                userId: userId,
                member: member,
                channel: channel,
                permission: perm
            )
        }
        
        /// Has the permissions at all.
        for perm in perms {
            if !hasPerm(perm) { return false }
        }
        
        /// Some permission require other permission first.
        /// These are the ones that Discord has documented.
        let requireSendMessages: [Permission] = [
            .mentionEveryone,
            .sendTtsMessages,
            .attachFiles,
            .embedLinks
        ]
        var needToCheckForSendMessagesPerm = false
        for perm in perms {
            if requireSendMessages.contains(perm) {
                needToCheckForSendMessagesPerm = true
                break
            }
        }
        
        /// If perms already contains `sendMessage`, then we've already checked for it.
        if needToCheckForSendMessagesPerm,
           !perms.contains(.sendMessages) {
            if !hasPerm(.sendMessages) { return false }
        }
        
        /// If perms already contains `viewChannel`, then we've already checked for it.
        if !perms.contains(.viewChannel) {
            /// Member must have `viewChannel` permission for anything else to begin with.
            if !hasPerm(.viewChannel) { return false }
        }
        
        /// For voice and stage channels, `connect` permission is necessary.
        /// If perms already contains `connect`, then we've already checked for it.
        if [.guildVoice, .guildStageVoice].contains(channel.type),
           !perms.contains(.connect) {
            /// Member must have `viewChannel` permission for anything else to begin with.
            if !hasPerm(.connect) { return false }
        }
        
        return true
    }
    
    /// Discouraged to use. Use `memberHasPermissions(userId:channelId:permissions:)` instead.
    public func _memberHasPermission(
        userId: String,
        member: Guild.Member,
        channel: DiscordChannel,
        permission perm: Permission
    ) -> Bool {
        
        var memberOverwriteDenies = false
        var roleOverwriteAllows = false
        var roleOverwriteDenies = false
        var everyoneIsAllowed = false
        var everyoneIsDenied = false
        
        for overwrite in (channel.permission_overwrites ?? []) {
            switch overwrite.type {
            case .member where overwrite.id == userId:
                if overwrite.allow.values.contains(perm) {
                    /// Has the most priority at this point, we can just return immediately.
                    return true
                }
                if overwrite.deny.values.contains(perm) {
                    memberOverwriteDenies = true
                }
            case .role where member.roles.contains(overwrite.id):
                if overwrite.allow.values.contains(perm) {
                    roleOverwriteAllows = true
                }
                if overwrite.deny.values.contains(perm) {
                    roleOverwriteDenies = true
                }
            case .role where overwrite.id == self.id: /// `@everyone` overwrites
                if overwrite.allow.values.contains(perm) {
                    everyoneIsAllowed = true
                }
                if overwrite.deny.values.contains(perm) {
                    everyoneIsDenied = true
                }
            default: break
            }
        }
        
        /// Checking these based on the Discord-said priority.
        if memberOverwriteDenies { return false }
        if roleOverwriteAllows { return true }
        if roleOverwriteDenies { return false }
        if everyoneIsAllowed { return true }
        if everyoneIsDenied { return false }
        
        /// Member has any roles that allow.
        for role in roles where member.roles.contains(role.id) {
            if role.permissions.values.contains(perm) {
                return true
            }
        }
        
        /// `@everyone` role allows.
        if let everyoneRole = self.roles.first(where: { $0.id == self.id }),
           everyoneRole.permissions.values.contains(perm) {
            return true
        }
        
        return false
    }
    
    /// Check to see if a member has a role
    public func memberHasRole(member: Guild.Member, roleId: String) -> Bool {
        if roleId == self.id {
            return true
        } else if member.roles.contains(roleId) {
            return true
        } else {
            return false
        }
    }
    
    private func requireMember(userId: String) throws -> Guild.Member {
        guard let member = self.members.first(where: { $0.user?.id == userId }) else {
            throw PermissionError.memberNotFound(userId: userId, guildId: self.id)
        }
        return member
    }
    
    private func requireChannel(channelId: String) throws -> DiscordChannel {
        guard let channel = self.channels.first(where: { $0.id == channelId }) else {
            throw PermissionError.channelNotFound(channelId: channelId, guildId: self.id)
        }
        return channel
    }
}
