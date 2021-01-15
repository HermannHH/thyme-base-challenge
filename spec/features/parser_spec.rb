require 'spec_helper'
require 'parser'

# Remove leading & trailing whitespace
# 1 - prepend text with <p>
# 1 - Append text with </p>
# 2 - Replace all line breaks with '</p><<p>'
# 3 - add highlight tags from array of words where p tags removed


RSpec.describe Parser, type: :request do

  subject { described_class.new(text: text, highlight_hashes: highlight_hashes) }
  let(:text) { "Line One

    Line Two"}

  let(:highlight_hashes) { [
      {
        start: 3,
        end: 3,
        comment: 'I highlight the word "Two" in sentence two'
      },
      {
        start: 0,
        end: 1,
        comment: 'I highlight the word "Line" in sentence one'
      },
      {
        start: 0,
        end: 3,
        comment: 'I overlap'
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
      expect(subject.highlight_hashes).to eq(highlight_hashes)
    end
  end

  describe "#generate_color" do
    it { expect(subject.send(:generate_color, highlight_hashes.first)).to eq('#1d85e1') }
    it { expect(subject.send(:generate_color, highlight_hashes.last)).to eq('#22045b') }
  end

  describe "#paint_highlight_hashes" do
    it { expect(subject.send(:paint_highlight_hashes)).to eq(painted_highlight_hashes) }
  end

  describe "#sanitized_string" do
    it { expect(subject.send(:sanitized_string)).to eq("Line One\n\nLine Two") }
  end

  describe "#line_breaks" do
    it { expect(subject.send(:line_breaks)).to eq([2]) }
  end

  describe "#entities" do
    it { expect(subject.send(:entities)).to eq(["Line ", "One", "", "Line ", "Two"]) }
  end

  describe "#apply_highlight_tags" do
    it { expect(subject.send(:apply_highlight_tags)).to eq(highlights_array) }
  end

  describe "#full_text_array" do
    it { expect(subject.send(:full_text_array)).to eq(full_text_array) }
  end

  describe "#wrap_text" do
    it { expect(subject.send(:wrap_text)).to eq(html_output) }
  end

  describe "#call" do
    it { expect(subject.call).to be_a_kind_of(Integer) }
  end

  private

  def painted_highlight_hashes
    highlight_hashes.map {|h|
      { start: h[:start], end: h[:end], comment: h[:comment], color: subject.send(:generate_color, h)}
    }
  end

  def highlights_array
    [
      "<mark title='I overlap' style='background-color: #22045b;'><mark title='I highlight the word \"Line\" in sentence one' style='background-color: #ec561a;'>Line </mark>",
      "One</mark>",
      "<mark title='I overlap' style='background-color: #22045b;'>Line </mark>",
      "<mark title='I highlight the word \"Two\" in sentence two' style='background-color: #1d85e1;'>Two</mark>"
    ]
  end

  def full_text_array
    output = highlights_array
    subject.send(:line_breaks).each do |line|
      output.insert(line, "</p><p>")
    end
    output
  end

  def html_output
    "<p><mark title='I overlap' style='background-color: #22045b;'><mark title='I highlight the word \"Line\" in sentence one' style='background-color: #ec561a;'>Line </mark>One</mark></p><p><mark title='I overlap' style='background-color: #22045b;'>Line </mark><mark title='I highlight the word \"Two\" in sentence two' style='background-color: #1d85e1;'>Two</mark></p>"
  end

end
