class RenameSessionIpAddressToDigest < ActiveRecord::Migration[8.1]
  def change
    rename_column :sessions, :ip_address, :ip_digest
  end
end
