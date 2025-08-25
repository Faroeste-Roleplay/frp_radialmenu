import { Box, createStyles } from '@mantine/core';
import { useEffect, useState } from 'react';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { fetchNui } from '../../../utils/fetchNui';
import { isIconUrl } from '../../../utils/isIconUrl';
import ScaleFade from '../../../transitions/ScaleFade';
import type { RadialMenuItem } from '../../../typings';
import { useLocales } from '../../../providers/LocaleProvider';
import LibIcon from '../../../components/LibIcon';

const useStyles = createStyles((theme) => ({
    wrapper: {
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
    },
    sector: {
        fill: 'rgba(20, 20, 20, 0.5)',
        color: theme.colors.dark[0],

        '&:hover': {
            fill: '#CC010090',
            stroke: "#CC010090",
            strokeWidth: 4,
            cursor: 'pointer',
            '> g > text, > g > svg > path': {
                fill: '#fff',
            },
        },
        '> g > text, > g > svg > path': {
            fill: theme.colors.dark[0],
            strokeWidth: 0,
            pointerEvents: 'all',
        },
    },
    backgroundCircle: {
        fill: "transparent",
        // stroke: "#ffffff90",
        // strokeWidth: 1,
    },
    centerCircle: {
        fill: 'rgba(20, 20, 20, 0.5)',
        color: '#fff',
        // stroke: '#fffffff90',
        // strokeWidth: 1,
        '&:hover': {
            cursor: 'pointer',
            fill: 'rgba(50, 50, 50, 0.50)',
        },
    },
    centerIconContainer: {
        position: 'absolute',
        top: '50%',
        left: '50%',
        transform: 'translate(-50%, -50%)',
        pointerEvents: 'none',
    },
    centerIcon: {
        color: '#fff',
    },
}));

//const calculateFontSize = (text: string): number => {
//    if (text.length > 20) return 10;
//    if (text.length > 15) return 10;
//    return 13;
//};

const splitTextIntoLines = (text: string, maxCharPerLine: number = 13): string[] => {
    const words = text.split(' ');
    const lines: string[] = [];
    let currentLine = words[0];

    for (let i = 1; i < words.length; i++) {
        if (currentLine.length + words[i].length + 1 <= maxCharPerLine) {
            currentLine += ' ' + words[i];
        } else {
            lines.push(currentLine);
            currentLine = words[i];
        }
    }
    lines.push(currentLine);
    return lines;
};

const PAGE_ITEMS = 1;

const RadialMenu: React.FC = () => {
    const { classes } = useStyles();
    const { locale } = useLocales();
    const newDimension = 350 * 1.1025;
    const [visible, setVisible] = useState(false);
    const [menuItems, setMenuItems] = useState<RadialMenuItem[]>([]);
    const [menu, setMenu] = useState<{ items: RadialMenuItem[]; sub?: boolean; page: number }>({
        items: [],
        sub: false,
        page: 1,
    });

    const radius = 250; // Raio externo do menu
    const innerRadius = 120; // Raio interno para criar o gap
    const centralRadius = 40; // Raio do círculo central

    const degToRad = (deg: number) => deg * (Math.PI / 180);

    const createSectorPath = (startAngle: number, endAngle: number, totalItems: number) => {
        if (totalItems === 1) {
            // Cria um círculo completo para um único item
            return `
          M ${-innerRadius}, 0
          a ${innerRadius},${innerRadius} 0 1,0 ${innerRadius * 2},0
          a ${innerRadius},${innerRadius} 0 1,0 ${-innerRadius * 2},0
          M ${-radius}, 0
          a ${radius},${radius} 0 1,1 ${radius * 2},0
          a ${radius},${radius} 0 1,1 ${-radius * 2},0
          Z
        `;
        } else {
            // Código existente para múltiplos itens
            const start = {
                x: radius * Math.cos(degToRad(startAngle)),
                y: radius * Math.sin(degToRad(startAngle)),
            };
            const end = {
                x: radius * Math.cos(degToRad(endAngle)),
                y: radius * Math.sin(degToRad(endAngle)),
            };

            const innerStart = {
                x: innerRadius * Math.cos(degToRad(startAngle)),
                y: innerRadius * Math.sin(degToRad(startAngle)),
            };
            const innerEnd = {
                x: innerRadius * Math.cos(degToRad(endAngle)),
                y: innerRadius * Math.sin(degToRad(endAngle)),
            };

            return `
          M ${innerStart.x} ${innerStart.y}
          L ${start.x} ${start.y}
          A ${radius} ${radius} 0 0 1 ${end.x} ${end.y}
          L ${innerEnd.x} ${innerEnd.y}
          A ${innerRadius} ${innerRadius} 0 0 0 ${innerStart.x} ${innerStart.y}
          Z
        `;
        }
    };

    const calculateTextPosition = (startAngle: number, endAngle: number) => {
        const angle = degToRad((startAngle + endAngle) / 2); // Ângulo médio do setor
        const textRadius = (radius + innerRadius) / 2; // Posição entre o raio interno e externo
        return {
            x: textRadius * Math.cos(angle),
            y: textRadius * Math.sin(angle),
        };
    };

    const changePage = async (increment?: boolean) => {
        setVisible(false);

        const didTransition: boolean = await fetchNui('radialTransition');

        if (!didTransition) return;

        setVisible(true);

        const newPage = increment ? menu.page + 1 : menu.page - 1;
        const maxPage = Math.ceil(menu.items.length / PAGE_ITEMS);

        setMenu((prev) => ({
            ...prev,
            page: Math.min(Math.max(newPage, 1), maxPage),
        }));
    };

    useEffect(() => {
        const menuItemsRendered = menu.items.filter(item => item.isEnabled !== false);
        const startIndex = PAGE_ITEMS * (menu.page - 1);
        const endIndex = startIndex + PAGE_ITEMS;

        if (menuItemsRendered.length <= PAGE_ITEMS) {
            setMenuItems(menuItemsRendered);
        } else {
            const items = menu.items.slice(startIndex, endIndex);
            if (menu.items.length > endIndex) {
                items[items.length - 1] = { icon: 'ellipsis-h', label: locale.ui.more, isMore: true };
            }
            setMenuItems(items);
        }
    }, [menu.items, menu.page, locale.ui.more]);

    useEffect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            if (event.key === 'Escape') {
                setVisible(false);
                fetchNui('radialClose');
            }
        };

        window.addEventListener('keydown', handleKeyDown);

        return () => {
            window.removeEventListener('keydown', handleKeyDown);
        };
    }, []);

    useNuiEvent('openRadialMenu', async (data: { items: RadialMenuItem[]; sub?: boolean; option?: string } | false) => {
        if (!data) return setVisible(false);
        let initialPage = 1;
        if (data.option) {
            data.items.findIndex(
                (item, index) => item.menu == data.option && (initialPage = Math.floor(index / PAGE_ITEMS) + 1)
            );
        }
        setMenu({ ...data, page: initialPage });
        setVisible(true);
    });


    useNuiEvent('refreshItems', (data: RadialMenuItem[]) => {
        setMenu({ ...menu, items: data });
    });

    const menuItemsRendered = menu.items.filter(item => item.isEnabled !== false);

    return (
        <Box
            className={classes.wrapper}
            onContextMenu={async () => {
                if (menu.page > 1) await changePage();
                else if (menu.sub) fetchNui('radialBack');
            }}
        >
            <ScaleFade visible={visible}>
                <svg
                    style={{ overflow: 'visible' }}
                    width={`${newDimension}px`}
                    height={`${newDimension}px`}
                    viewBox="0 0 350 350"
                >
                    <g transform="translate(175, 175)">
                        <circle r={radius} className={classes.backgroundCircle} />
                        {menuItemsRendered.map((item, index) => {
                            const totalItems = menuItemsRendered.length;
                            let startAngle, endAngle;

                            if (totalItems === 1) {
                                startAngle = 0;
                                endAngle = 360;
                                return (
                                    <g key={index}>
                                        <path
                                            d={createSectorPath(startAngle, endAngle, totalItems)}
                                            className={classes.sector}
                                            onClick={async () => {
                                                if (!item.isMore) {
                                                    const originalIndex = menu.items.findIndex(menuItem =>
                                                        menuItem.label === item.label &&
                                                        menuItem.icon === item.icon
                                                    );
                                                    fetchNui('radialClick', originalIndex);
                                                } else {
                                                    await changePage(true);
                                                }
                                            }}
                                        />
                                        <LibIcon
                                            x={-15}
                                            y={radius - 80}
                                            icon={item.icon as IconProp}
                                            width={30}
                                            height={30}
                                            color={"white"}
                                            fixedWidth
                                            style={{ pointerEvents: 'none' }}
                                        />
                                        <text
                                            x={0}
                                            y={radius - 45}
                                            textAnchor="middle"
                                            dominantBaseline="middle"
                                            fill="#fff"
                                            fontSize={"16px"}
                                            fontWeight="bold"
                                            style={{ pointerEvents: 'none', textTransform: "uppercase" }}
                                        >
                                            {item.label}
                                        </text>
                                    </g>
                                );
                            } else {
                                const sectorAngle = 360 / totalItems;
                                startAngle = sectorAngle * index;
                                endAngle = startAngle + sectorAngle;

                                const textPosition = calculateTextPosition(startAngle, endAngle);

                                return (
                                    <g key={index}>
                                        <path
                                            d={createSectorPath(startAngle, endAngle, totalItems)}
                                            className={classes.sector}
                                            onClick={async () => {
                                                if (!item.isMore) {
                                                    const originalIndex = menu.items.findIndex(menuItem =>
                                                        menuItem.label === item.label &&
                                                        menuItem.icon === item.icon
                                                    );
                                                    fetchNui('radialClick', originalIndex);
                                                } else {
                                                    await changePage(true);
                                                }
                                            }}
                                        />
                                        {typeof item.icon === 'string' && isIconUrl(item.icon) ? (
                                            <image
                                                href={item.icon}
                                                width={20}
                                                height={20}
                                                x={textPosition.x}
                                                y={textPosition.y}
                                            />
                                        ) : (
                                            <LibIcon
                                                x={textPosition.x - 9}
                                                y={textPosition.y - 30.5}
                                                icon={item.icon as IconProp}
                                                width={20}
                                                height={20}
                                                color={"white"}
                                                fixedWidth
                                                style={{ pointerEvents: 'none', }}
                                            />
                                        )}
                                        <text
                                            x={textPosition.x}
                                            y={textPosition.y + 10}
                                            textAnchor="middle"
                                            dominantBaseline="middle"
                                            fontFamily='Cera Pro'
                                            fill="#fff"
                                            fontSize={"16px"}
                                            fontWeight="bold"
                                            style={{ pointerEvents: 'none', textTransform: "uppercase" }}
                                        >
                                            {splitTextIntoLines(item.label, 12).map((line, index) => (
                                                <tspan x={textPosition.x} dy={index === 0 ? 0 : '1.2em'} key={index}>
                                                    {line}
                                                </tspan>
                                            ))}

                                        </text>
                                    </g>
                                );
                            }
                        })}
                        {/* Círculo Central */}
                        <g
                            transform='translate(-40,-40)'
                            width="50"
                            height="50"
                            viewBox="0 0 50 50"
                            fill="none"
                            xmlns="http://www.w3.org/2000/svg"
                            onClick={async () => {
                                if (menu.page > 1) await changePage();
                                else if (menu.sub) fetchNui('radialBack');
                                else {
                                    setVisible(false);
                                    fetchNui('radialClose');
                                }
                            }}
                        >
                            <circle cx={centralRadius} className={classes.centerCircle} cy={centralRadius} r="50" 
                                // stroke="white" stroke-opacity="0.5" 
                            />
                            {/* <circle cx={centralRadius} cy={centralRadius} r="50" stroke="white" stroke-opacity="0.5" /> */}

                            {
                                menu.sub ? (
                                    <path style={{ pointerEvents: "none" }} fill-rule="evenodd" clip-rule="evenodd" d="M39.8322 30.0009C39.3462 30.0009 38.88 30.194 38.5363 30.5377C38.1926 30.8814 37.9995 31.3475 37.9995 31.8336C37.9995 32.3197 38.1926 32.7858 38.5363 33.1295C38.88 33.4732 39.3462 33.6663 39.8322 33.6663H44.8318C46.0974 33.6909 47.303 34.211 48.1893 35.1148C49.0757 36.0186 49.5722 37.234 49.5722 38.5C49.5722 39.7659 49.0757 40.9813 48.1893 41.8851C47.303 42.7889 46.0974 43.309 44.8318 43.3337H36.6653V40.1668C36.6653 39.8044 36.5577 39.4501 36.3564 39.1488C36.155 38.8475 35.8688 38.6127 35.534 38.474C35.1991 38.3353 34.8307 38.299 34.4752 38.3697C34.1198 38.4404 33.7933 38.6149 33.537 38.8711L28.5411 43.867C28.2837 44.1226 28.108 44.4489 28.0362 44.8046C27.9645 45.1602 27.9998 45.5291 28.1379 45.8646C28.2271 46.0845 28.3603 46.2843 28.5374 46.4639L33.537 51.4634C33.7933 51.7196 34.1198 51.8941 34.4752 51.9648C34.8307 52.0355 35.1991 51.9992 35.534 51.8605C35.8688 51.7218 36.155 51.487 36.3564 51.1857C36.5577 50.8844 36.6653 50.5301 36.6653 50.1677V46.999H44.8318C45.9584 47.0156 47.077 46.8079 48.1227 46.3883C49.1683 45.9686 50.1201 45.3452 50.9227 44.5543C51.7252 43.7635 52.3625 42.8209 52.7975 41.7816C53.2325 40.7422 53.4565 39.6267 53.4565 38.5C53.4565 37.3732 53.2325 36.2577 52.7975 35.2184C52.3625 34.179 51.7252 33.2365 50.9227 32.4456C50.1201 31.6548 49.1683 31.0314 48.1227 30.6117C47.077 30.192 45.9584 29.9844 44.8318 30.0009H39.8322Z" fill="white" />
                                ) : (
                                    <>
                                        <path transform='translate(29,29)'  style={{ pointerEvents: "none" }} d="M2.10977 21.9886C1.56411 22.0203 1.02748 21.8389 0.61303 21.4827C-0.204343 20.6604 -0.204343 19.3325 0.61303 18.5102L18.5108 0.612371C19.361 -0.183134 20.695 -0.138912 21.4905 0.711228C22.2098 1.48001 22.2518 2.66164 21.5886 3.47943L3.5854 21.4827C3.17629 21.8338 2.64827 22.0149 2.10977 21.9886Z" fill="white"/>
                                        <path transform='translate(29,29)' style={{ pointerEvents: "none" }} d="M19.9865 21.9886C19.4335 21.9863 18.9035 21.7667 18.5108 21.3773L0.612955 3.47935C-0.144299 2.59506 -0.0413459 1.26424 0.84295 0.506918C1.63221 -0.168973 2.7962 -0.168973 3.58539 0.506918L21.5886 18.4048C22.4386 19.2005 22.4825 20.5346 21.6868 21.3845C21.6551 21.4183 21.6224 21.451 21.5886 21.4827C21.1478 21.866 20.5676 22.0492 19.9865 21.9886Z" fill="white"/>
                                    </>
                                )
                            }
                        </g>

                    </g>
                </svg>
            </ScaleFade>
        </Box>
    );
};

export default RadialMenu;
