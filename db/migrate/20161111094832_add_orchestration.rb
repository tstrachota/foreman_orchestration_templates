class AddOrchestration < ActiveRecord::Migration
  def change
    create_table :orchestration_jobs do |t|
      t.string :name, :length => 254
      t.string :task_id

      t.timestamps
    end

    create_table :orchestration_configurations do |t|
      t.string :description, :length => 254
      t.text :values

      t.references :template, :null => false
      t.references :orchestration_job, :null => false

       t.timestamps
    end

    add_foreign_key :orchestration_configurations, :templates, :name => :configurations_template_id_fk
    add_foreign_key :orchestration_configurations, :orchestration_jobs, :name => :configurations_job_id_fk
  end
end
