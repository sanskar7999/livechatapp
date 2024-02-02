class Room < ApplicationRecord
    has_many :messages, dependent: :destroy
    validates_uniqueness_of :name
    validates :name, presence: true
    before_validation :convert_name_to_lowercase
    scope :public_rooms, -> { where(is_private: false) }
    after_create_commit {broadcast_append_to "rooms"}
    has_many :participants, dependent: :destroy
    
    after_create_commit { broadcast_if_public }

    def broadcast_if_public
    broadcast_append_to "rooms" unless self.is_private
    end

    def self.create_private_room(users, room_name)
    single_room = Room.create(name: room_name, is_private: true)
    users.each do |user|
        Participant.create(user_id: user.id, room_id: single_room.id )
    end
    single_room
    end

    private
    def convert_name_to_lowercase
        self.name = name.downcase if name.present?
    end
end
