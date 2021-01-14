require 'spec_helper'
require 'parser'

RSpec.describe Parser, type: :request do

  subject { described_class.new(text: text, highlight_hashes: highlight_hashes) }
  let(:text) { %q{
    Line One

    Line Two
  }}

  let(:highlight_hashes) { [
      {
        start: 3,
        end: 4,
        comment: 'I highlight the word "Two" in sentence two'
      },
      {
        start: 0,
        end: 1,
        comment: 'I highlight the word "Line" in sentence one'
      }
    ]
  }

  context 'class setup & initialization' do
    it 'instantiates the class with 2 arguments' do
      expect(subject).to be_an_instance_of(Parser)
    end

    it 'sets text to the first argument' do
      expect(subject.text).to eq(text)
    end

    it 'sets highlight_hashes to the second argument' do
      binding.pry
      expect(subject.highlight_hashes).to eq(highlight_hashes)
    end
  end

  describe ".call" do
    it { expect(subject.call).to eq(output) }
  end

  describe "#sanitized_string" do
    it { expect(subject.send(:sanitized_string)).to eq("Line One \\n\\n Line Two") }
  end

  describe "#words_array" do
    it { expect(subject.send(:words_array).count).to eq(4) }
  end

  describe "#line_break_index" do
    it { expect(subject.send(:line_break_index)).to eq([2]) }
  end

  describe "#sort_highlight_hashes" do
    it { expect(subject.send(:sort_highlight_hashes).first[:start]).to eq(0) }
    it { expect(subject.send(:sort_highlight_hashes).last[:start]).to eq(3) }
  end

  describe "#apply_highlight_tags" do
    it { expect(subject.send(:apply_highlight_tags)).to eq(['<mark>Line</mark>', 'One', 'Line', '<mark>Two</mark>']) }
  end

  describe "#apply_line_breaks" do
    it { expect(subject.send(:apply_line_breaks)).to eq(['<mark>Line</mark>', 'One', '/n/n', 'Line', '<mark>Two</mark>']) }
  end

  describe "#construct_html" do
    it { expect(subject.send(:construct_html)).to eq(output) }
  end

  private

  def output
    "<p><mark>Line</mark> One</p><p>Line <mark>Two</mark></p>"
  end

end
