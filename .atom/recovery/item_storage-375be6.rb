# == Schema Information
#
# Table name: item_storages
#
#  id         :integer          not null, primary key
#  item_type  :integer          not null
#  code       :string(255)      not null
#  service    :integer          default(0), not null
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ItemStorage < ActiveRecord::Base
  has_one :suppliers_item
  has_one :variant

  enum service: { e_logit: 0 }
  enum item_type: { set_item: 0, single_item: 1,
                    single: 2, pack: 3, case: 4, paper: 5, office_finc: 6 }

  validates :service, :item_type, presence: true

  STR_CODES_FOR_ITEM_TYPE = {
    set_item: 'SU',
    single_item: 'SI',
    single: 'PCS',
    pack: 'CTN',
    case: 'CS',
    paper: 'OT',
    office_finc: 'FI'
  }.freeze

  NUMERIC_CODE_LENGTH = 4

  class << self
    def new_codes_for_select(item_storage = nil)
      item_types.keys.each_with_object({}) do |item_type, h|
        h[new_code_of(item_type)] = item_type
        h[item_storage.code] = item_storage.item_type if item_storage.try(:item_type) == item_type
      end
    end

    def new_code_of(item_type)
      STR_CODES_FOR_ITEM_TYPE[item_type.to_sym] + new_numeric_code(item_type)
    end

    private

    def new_numeric_code(item_type)
      new_number = send(item_type).count + 1
      format("%0#{NUMERIC_CODE_LENGTH}d", new_number)
    end
  end
end
