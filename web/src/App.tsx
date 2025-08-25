import { useNuiEvent } from './hooks/useNuiEvent';
import { setClipboard } from './utils/setClipboard';
import { fetchNui } from './utils/fetchNui';
import Dev from './features/dev';
import { isEnvBrowser } from './utils/misc';
import RadialMenu from './features/menu/radial';
import { theme } from './theme';
import { MantineProvider } from '@mantine/core';
import { useConfig } from './providers/ConfigProvider';

const App: React.FC = () => {
  const { config } = useConfig();

  useNuiEvent('setClipboard', (data: string) => {
    setClipboard(data);
  });

  fetchNui('init');

  return (
    <MantineProvider withNormalizeCSS withGlobalStyles theme={{ ...theme, ...config }}>
      <RadialMenu />
      {isEnvBrowser() && <Dev />}
    </MantineProvider>
  );
};

export default App;
