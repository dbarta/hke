require "rails_helper"

RSpec.describe Hke::ContactPerson, type: :model do
  it { should have_many(:relations).dependent(:destroy) }
  it { should have_many(:deceased_people).through(:relations) }
  it { should have_many(:future_messages).through(:relations) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:gender) }
  it { should validate_presence_of(:phone) }

  it do
    should validate_inclusion_of(:gender)
      .in_array(["male", "female"])
  end

  it { should accept_nested_attributes_for(:relations).allow_destroy(true).reject_if(:all_blank) }
end
