import { ActionIcon, Button, Divider, Drawer, Stack, Tooltip } from '@mantine/core';

import { useState } from 'react';
import { debugRadial } from './debug/radial';
import LibIcon from '../../components/LibIcon';

const Dev: React.FC = () => {
  const [opened, setOpened] = useState(false);

  return (
    <>
      <Tooltip label="Developer drawer" position="bottom">
        <ActionIcon
          onClick={() => setOpened(true)}
          radius="xl"
          variant="filled"
          color="orange"
          sx={{ position: 'absolute', bottom: 0, right: 0, width: 50, height: 50 }}
          size="xl"
          mr={50}
          mb={50}
        >
          <LibIcon icon="wrench" fontSize={24} />
        </ActionIcon>
      </Tooltip>

      <Drawer position="left" onClose={() => setOpened(false)} opened={opened} title="Developer drawer" padding="xl">
        <Stack>
          <Button fullWidth onClick={() => debugRadial()}>
            Open radial menu
          </Button>
        </Stack>
      </Drawer>
    </>
  );
};

export default Dev;
