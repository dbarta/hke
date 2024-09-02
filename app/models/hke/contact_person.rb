module Hke
  class ContactPerson < ApplicationRecord
    include Hke::Addressable
    has_person_name
    has_many :relations, dependent: :destroy
    has_many :deceased_people, through: :relations
    has_many :future_messages, through: :relations
    has_one :preference, as: :preferring, dependent: :destroy
    validates :first_name, :last_name, :gender, :phone, presence: {message: :presence}
    validates :gender, inclusion: {in: ["male", "female"], message: :gender_invalid}
    accepts_nested_attributes_for :relations, allow_destroy: true, reject_if: :all_blank
    after_commit :process_future_messages

    private

    def process_future_messages
      relations.each(&:process_future_messages)
    end
  end
end
