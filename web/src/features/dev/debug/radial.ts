import { debugData } from '../../../utils/debugData';
import type { RadialMenuItem } from '../../../typings';

export const debugRadial = () => {
    debugData<{ items: RadialMenuItem[]; sub?: boolean }>([
        {
            action: 'openRadialMenu',
            data: {
                items: [
                    { icon: 'fa-regular fa-bookmark', label: 'Dançar' },
                    { icon: 'palette', label: 'Extrair Sangue' },
                    { icon: 'palette', label: 'Aplicar Plastica' },
                    { icon: 'palette', label: 'Adicionar Licença de Armas' },
                    { icon: 'palette', label: 'Adicionar Licença de Armas' },
                    { icon: 'palette', label: 'Adicionar Licença de Armas' },
                ],
            },
        },
    ]);
};
