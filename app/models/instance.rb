class Instance < ActiveRecord::Base
  include Provider
  include Aws

  validates_presence_of :name, :os, :subnet
  belongs_to :subnet

  has_many :instance_groups, dependent: :delete_all
  has_many :instance_roles, dependent: :delete_all
  has_many :groups, through: :instance_groups
  has_many :roles, through: :instance_roles
  
  before_create :ensure_has_ip
  validate :ip_address_must_be_within_subnet

  def ensure_has_ip
    if self.ip_address.blank?
      return false # TODO set this to a valid IP in subnet cidr
    end
    true
  end

  def ip_address_must_be_within_subnet
    # TODO fix
    true
  end
  def add_progress
    debug "Adding progress to instance!"
    PrivatePub.publish_to "/scenarios/#{self.subnet.cloud.scenario.id}", instance_progress: 1
  end
  def debug(message)
    log = self.subnet.cloud.scenario.log
    self.subnet.cloud.scenario.update_attributes(log: log + message + "\n")
    PrivatePub.publish_to "/scenarios/#{self.subnet.cloud.scenario.id}", log_message: message
  end
  

  # Handy user methods
  def administrators
    groups = self.instance_groups.select {|instance_group| instance_group.administrator }.map {|instance_group| instance_group.group}
    users = groups.inject([]) {|users, group| users.concat(group.players) }
  end

  def users
    groups = self.instance_groups.select {|instance_group| !instance_group.administrator }.map {|instance_group| instance_group.group}
    users = groups.inject([]) {|users, group| users.concat(group.players) }
  end

  def add_administrator(group)
    InstanceGroup.create(group: group, instance: self, administrator: true)
  end

  def add_user(group)
    InstanceGroup.create(group: group, instance: self, administrator: false)
  end

end
