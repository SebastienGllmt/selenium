# frozen_string_literal: true

# Licensed to the Software Freedom Conservancy (SFC) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The SFC licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

require File.expand_path('../spec_helper', __dir__)

module Selenium
  module WebDriver
    module Chrome
      describe Options do
        subject(:options) { described_class.new }

        describe '#initialize' do
          it 'sets passed args' do
            opt = Options.new(args: %w[foo bar])
            expect(opt.args.to_a).to eq(%w[foo bar])
          end

          it 'sets passed prefs' do
            opt = Options.new(prefs: {foo: 'bar'})
            expect(opt.prefs[:foo]).to eq('bar')
          end

          it 'sets passed binary value' do
            opt = Options.new(binary: '/foo/bar')
            expect(opt.binary).to eq('/foo/bar')
          end

          it 'sets passed extensions' do
            opt = Options.new(extensions: ['foo.crx', 'bar.crx'])
            expect(opt.extensions).to eq(['foo.crx', 'bar.crx'])
          end

          it 'sets passed options' do
            opt = Options.new(options: {foo: 'bar'})
            expect(opt.options[:foo]).to eq('bar')
          end

          it 'sets passed emulation options' do
            opt = Options.new(emulation: {foo: 'bar'})
            expect(opt.emulation[:foo]).to eq('bar')
          end
        end

        describe '#add_extension' do
          it 'adds an extension' do
            allow(File).to receive(:file?).with('/foo/bar.crx').and_return(true)

            options.add_extension('/foo/bar.crx')
            expect(options.extensions).to include('/foo/bar.crx')
          end

          it 'raises error when the extension file is missing' do
            allow(File).to receive(:file?).with('/foo/bar').and_return false

            expect { options.add_extension('/foo/bar') }.to raise_error(Error::WebDriverError)
          end

          it 'raises error when the extension file is not .crx' do
            allow(File).to receive(:file?).with('/foo/bar').and_return true

            expect { options.add_extension('/foo/bar') }.to raise_error(Error::WebDriverError)
          end
        end

        describe '#add_encoded_extension' do
          it 'adds an encoded extension' do
            options.add_encoded_extension('foo')
            expect(options.encoded_extensions).to include('foo')
          end
        end

        describe '#binary=' do
          it 'sets the binary path' do
            options.binary = '/foo/bar'
            expect(options.binary).to eq('/foo/bar')
          end
        end

        describe '#add_argument' do
          it 'adds a command-line argument' do
            options.add_argument('foo')
            expect(options.args.to_a).to eq(['foo'])
          end
        end

        describe '#headless!' do
          it 'should add necessary command-line arguments' do
            options.headless!
            expect(options.args.to_a).to eql(['--headless'])
          end
        end

        describe '#add_option' do
          it 'adds an option' do
            options.add_option(:foo, 'bar')
            expect(options.options[:foo]).to eq('bar')
          end
        end

        describe '#add_preference' do
          it 'adds a preference' do
            options.add_preference(:foo, 'bar')
            expect(options.prefs[:foo]).to eq('bar')
          end
        end

        describe '#add_emulation' do
          it 'add an emulated device by name' do
            options.add_emulation(device_name: 'iPhone 6')
            expect(options.emulation).to eq(deviceName: 'iPhone 6')
          end

          it 'adds emulated device metrics' do
            options.add_emulation(device_metrics: {width: 400})
            expect(options.emulation).to eq(deviceMetrics: {width: 400})
          end

          it 'adds emulated user agent' do
            options.add_emulation(user_agent: 'foo')
            expect(options.emulation).to eq(userAgent: 'foo')
          end
        end

        describe '#as_json' do
          it 'encodes extensions to base64' do
            allow(File).to receive(:file?).and_return(true)
            options.add_extension('/foo.crx')

            allow(File).to receive(:open).and_yield(instance_double(File, read: :foo))
            expect(Base64).to receive(:strict_encode64).with(:foo)
            options.as_json
          end

          it 'returns a JSON hash' do
            allow(File).to receive(:open).and_return('bar')
            opts = Options.new(args: ['foo'],
                               binary: '/foo/bar',
                               prefs: {a: 1},
                               extensions: ['/foo.crx'],
                               options: {foo: :bar},
                               emulation: {device_name: 'mine'})

            json = opts.as_json['goog:chromeOptions']
            expect(json).to eq('args' => ['foo'], 'binary' => '/foo/bar',
                               'prefs' => {'a' => 1},
                               'extensions' => ['bar'],
                               'foo' => 'bar',
                               'mobileEmulation' => {'deviceName' => 'mine'})
          end
        end
      end # Options
    end # Chrome
  end # WebDriver
end # Selenium
