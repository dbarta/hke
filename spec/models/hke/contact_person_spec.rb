require "rails_helper"

RSpec.describe Hke::ContactPerson, type: :model do
  it { should have_many(:relations).dependent(:destroy) }
  it { should have_many(:deceased_people).through(:relations) }
  it { should have_many(:future_messages).through(:relations) }

  it { should validate_presence_of(:first_name).with_message(:presence) }
  it { should validate_presence_of(:last_name).with_message(:presence) }
  it { should validate_presence_of(:gender).with_message(:presence) }
  it { should validate_presence_of(:phone).with_message(:presence) }

  it do
    should validate_inclusion_of(:gender)
      .in_array(["male", "female"])
      .with_message(:gender_invalid)
  end

  it { should accept_nested_attributes_for(:relations).allow_destroy(true).reject_if(:all_blank) }
end
