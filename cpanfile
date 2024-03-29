requires 'Adapter::Async', '>= 0.019';
requires 'Bytes::Random::Secure', '>= 0.29';
requires 'Cache::LRU', '>= 0.04';
requires 'Check::UnitCheck';
requires 'curry', '>= 1.001000';
requires 'Dir::Self', 0;
requires 'File::ShareDir', '>= 1.118';
requires 'Future', '>= 0.47';
requires 'Future::AsyncAwait', '>= 0.49';
requires 'HTTP::Request', 0;
requires 'indirect', 0;
requires 'IO::Async::SSL', '>= 0.22';
requires 'JSON::MaybeUTF8', '>= 2.000';
requires 'JSON::MaybeXS', '>= 1.004003';
requires 'Log::Any', '>= 1.709';
requires 'namespace::clean', 0;
requires 'Net::Async::HTTP', '>= 0.48';
requires 'Net::Async::OAuth::Client', 0;
requires 'Net::Async::WebSocket::Client', 0;
requires 'Path::Tiny', '>= 0.118';
requires 'Ryu', '>= 2.007';
requires 'Ryu::Async', '>= 0.019';
requires 'Syntax::Keyword::Try', '>= 0.21';
requires 'Time::Moment', '>= 0.44';
requires 'URI', '>= 5.09';
requires 'URI::QueryParam', 0;
requires 'URI::Template', '>= 0.24';
requires 'URI::wss', 0;

on 'develop' => sub {
    requires 'Test::CPANfile', '>= 0.02';
    requires 'Devel::Cover::Report::Coveralls', '>= 0.11';
    requires 'Devel::Cover';
};
