require 'rails_helper'

describe User do
  it "has a valid factory" do
    expect(build(:user)).to be_valid
  end

  it "prints full name appropriately" do
  	user = build(:user)

  	expect(user.full_name).to eq("#{user.first_name.capitalize} #{user.last_name.capitalize}")
  end

  it "breaks when role is invalid" do 
  	user = build(:user, role: 'fakerole')

  	expect(user).not_to be_valid
  end

end