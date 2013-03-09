
class CreateOauth2ProviderModels < ActiveRecord::Migration
  def up
    Songkick::OAuth2::Model::Schema.up
  end

  def down
    Songkick::OAuth2::Model::Schema.down
  end
end
