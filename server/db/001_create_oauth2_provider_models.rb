
class CreateOauth2ProviderModels < ActiveRecord::Migration
  def up
    OAuth2::Model::Schema.up
  end

  def down
    OAuth2::Model::Schema.down
  end
end
