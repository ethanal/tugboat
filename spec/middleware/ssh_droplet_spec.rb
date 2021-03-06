require 'spec_helper'

describe Tugboat::Middleware::SSHDroplet do
  include_context "spec"

  before do
    allow(Kernel).to receive(:exec)
  end

  describe ".call" do

    it "exec ssh with correct options" do
      expect(Kernel).to receive(:exec).with("ssh",
                        "-o", "IdentitiesOnly=yes",
                        "-o", "LogLevel=ERROR",
                        "-o", "StrictHostKeyChecking=no",
                        "-o", "UserKnownHostsFile=/dev/null",
                        "-i", File.expand_path(ssh_key_path),
                        "-p", ssh_port,
                        "#{ssh_user}@#{droplet_ip_private}")

      env["droplet_ip"] = droplet_ip
      env["droplet_ip_private"] = droplet_ip_private
      env["config"] = config

      described_class.new(app).call(env)
    end

    it "executes ssh with custom options" do
      expect(Kernel).to receive(:exec).with("ssh",
                        "-o", "IdentitiesOnly=yes",
                        "-o", "LogLevel=ERROR",
                        "-o", "StrictHostKeyChecking=no",
                        "-o", "UserKnownHostsFile=/dev/null",
                        "-i", File.expand_path(ssh_key_path),
                        "-p", ssh_port,
                        "-e",
                        "-q",
                        "-X",
                        "#{ssh_user}@#{droplet_ip}",
                        "echo hello")

      env["droplet_ip"] = droplet_ip
      env["droplet_ip_private"] = droplet_ip_private
      env["config"] = config
      env["user_droplet_ssh_command"] = "echo hello"
      env["user_droplet_use_public_ip"] = true
      env["user_droplet_ssh_opts"] = "-e -q -X"

      described_class.new(app).call(env)
    end

    it "executes ssh using public ip setting from config" do
      config.data["use_public_ip"] = true

      expect(Kernel).to receive(:exec).with("ssh",
                        "-o", "IdentitiesOnly=yes",
                        "-o", "LogLevel=ERROR",
                        "-o", "StrictHostKeyChecking=no",
                        "-o", "UserKnownHostsFile=/dev/null",
                        "-i", File.expand_path(ssh_key_path),
                        "-p", ssh_port,
                        "#{ssh_user}@#{droplet_ip}")

      env["droplet_ip"] = droplet_ip
      env["droplet_ip_private"] = droplet_ip_private
      env["config"] = config

      described_class.new(app).call(env)
    end

  end

end
