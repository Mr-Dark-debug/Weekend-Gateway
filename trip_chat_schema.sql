-- Trip Messages Table
CREATE TABLE trip_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

COMMENT ON TABLE trip_messages IS 'Stores chat messages related to a specific trip.';
COMMENT ON COLUMN trip_messages.content IS 'The text content of the chat message.';

-- Indexes
CREATE INDEX idx_trip_messages_trip_id ON trip_messages(trip_id);
CREATE INDEX idx_trip_messages_user_id ON trip_messages(user_id);
CREATE INDEX idx_trip_messages_created_at ON trip_messages(created_at);
CREATE INDEX idx_trip_messages_trip_id_created_at ON trip_messages(trip_id, created_at);

-- RLS Policy Considerations (Conceptual - to be implemented later if needed)
--
-- 1. Allow trip members (owner or collaborators) to select messages for their trip:
--    CREATE POLICY "Allow trip members to read messages"
--    ON trip_messages FOR SELECT
--    USING (
--      auth.uid() = (SELECT user_id FROM trips WHERE id = trip_id) OR -- Owner
--      EXISTS (
--        SELECT 1 FROM trip_collaborators
--        WHERE trip_collaborators.trip_id = trip_messages.trip_id
--        AND trip_collaborators.user_id = auth.uid()
--      )
--    );
--
-- 2. Allow trip members to insert messages for their trip:
--    CREATE POLICY "Allow trip members to send messages"
--    ON trip_messages FOR INSERT
--    WITH CHECK (
--      auth.uid() = user_id AND -- User can only send messages as themselves
--      (
--        auth.uid() = (SELECT user_id FROM trips WHERE id = trip_id) OR -- Owner
--        EXISTS (
--          SELECT 1 FROM trip_collaborators
--          WHERE trip_collaborators.trip_id = trip_messages.trip_id
--          AND trip_collaborators.user_id = auth.uid()
--          AND trip_collaborators.role IN ('editor', 'owner') -- Or any role allowed to chat
--        )
--      )
--    );
--
-- 3. Restrict UPDATE/DELETE (chats are often append-only, or only allow deleting own messages shortly after sending)
--    CREATE POLICY "Allow users to delete their own messages (within a time limit - advanced)"
--    ON trip_messages FOR DELETE
--    USING (
--      auth.uid() = user_id AND
--      created_at > (NOW() - INTERVAL '5 minutes') -- Example: can only delete within 5 minutes
--    );
--
--    -- More commonly, updates might not be allowed at all for chat messages.
--    CREATE POLICY "Disallow updates on messages"
--    ON trip_messages FOR UPDATE
--    USING (false);
