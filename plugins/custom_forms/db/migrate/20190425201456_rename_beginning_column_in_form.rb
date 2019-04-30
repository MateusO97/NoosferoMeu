class RenameBeginningColumnInForm < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      change_table :custom_forms_plugin_forms do |t|
        dir.up   { t.rename :begining, :beginning }
        dir.down { t.rename :beginning, :begining }
      end
    end
  end
end
