<%@ Page Language="C#" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Email Builder - SharePoint Edition</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; margin: 0; padding: 0; }
        input, textarea, select { background-color: white !important; }
        input::-webkit-scrollbar, textarea::-webkit-scrollbar { width: 4px; height: 4px; }
        input::-webkit-scrollbar-track, textarea::-webkit-scrollbar-track { background: white; }
        input::-webkit-scrollbar-thumb, textarea::-webkit-scrollbar-thumb { background: white; border-radius: 10px; }
        .custom-scrollbar::-webkit-scrollbar { width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body class="bg-slate-50 text-slate-900">
    <div id="root"></div>

    <script type="module">
        import React, { useState, useEffect, useCallback, useMemo } from 'https://esm.sh/react@19.2.4';
        import ReactDOM from 'https://esm.sh/react-dom@19.2.4/client';

        const ModuleType = {
            HEADER_LOGO: 'HEADER_LOGO',
            BANNER: 'BANNER',
            TEXT: 'TEXT',
            IMAGE: 'IMAGE',
            TABLE_COL_HEADER: 'TABLE_COL_HEADER',
            TABLE_ROW_HEADER: 'TABLE_ROW_HEADER',
            CTA: 'CTA',
            FOOTER_BANNER: 'FOOTER_BANNER',
            SIGNATURE: 'SIGNATURE'
        };

        const DEFAULT_MODULES = [
            { id: 'm1', type: ModuleType.HEADER_LOGO, properties: { imageUrl: 'https://raw.githubusercontent.com/Uniper-Bulawa/dot-email-assets/main/report_logo_A.png', align: 'right', altText: 'Unternehmens-Header' } },
            { id: 'm2', type: ModuleType.BANNER, properties: { title: 'Gap Respondent Change', color: '#0078DC', secondaryColor: '#135B8B' } },
            { id: 'm3', type: ModuleType.TEXT, properties: { content: 'Dear colleague,\n\nYou have been assigned to please review and respond to the following gap:' } },
            { id: 'm4', type: ModuleType.IMAGE, properties: { imageUrl: 'cid:report.png', altText: 'Screenshot' } },
            { id: 'm5', type: ModuleType.TABLE_ROW_HEADER, properties: { rows: [{ label: 'Topic:', value: 'Gap #5' }, { label: 'Gap Type:', value: 'Information' }] } },
            { id: 'm6', type: ModuleType.CTA, properties: { content: 'Visit our platform.', buttonText: 'BDP', url: '#' } },
            { id: 'm7', type: ModuleType.FOOTER_BANNER, properties: { imageUrl: 'https://raw.githubusercontent.com/Uniper-Bulawa/dot-email-assets/main/report_dot_footer.png' } },
            { id: 'm8', type: ModuleType.SIGNATURE, properties: { content: 'Generated email.', imageUrl: 'https://raw.githubusercontent.com/Uniper-Bulawa/dot-email-assets/main/report_logo_DOT.png' } }
        ];

        const renderModuleToHtml = (module) => {
            const { type, properties } = module;
            switch (type) {
                case ModuleType.HEADER_LOGO:
                    return `<div style="text-align: ${properties.align || 'right'}; margin-bottom: 20px; margin-top: 40px;"><img src="${properties.imageUrl}" width="auto" style="display: inline-block; width: auto; max-width: 640px; height: auto;"></div>`;
                case ModuleType.BANNER:
                    return `<div style="margin-top: 25px; text-align: center; padding: 12px; background: ${properties.color}; background: linear-gradient(30deg, ${properties.color} 0%, ${properties.secondaryColor} 100%); border-radius: 12px;"><h2 style="color: #ffffff; margin: 0; font-size: 20px; font-weight: 600;">${properties.title}</h2></div>`;
                case ModuleType.TEXT:
                    return properties.content?.split('\n').map(p => p.trim() ? `<p style="margin-bottom: 15px; margin-top: 25px; font-size: 15px;">${p}</p>` : '').join('') || '';
                case ModuleType.IMAGE:
                    return `<div style="margin: 25px 0;"><img src="${properties.imageUrl}" width="640" style="display: block; width: 100%; max-width: 640px; height: auto; border: 1px solid #dddddd; border-radius: 4px;"></div>`;
                case ModuleType.TABLE_ROW_HEADER:
                    const rowsHtml = (properties.rows || []).map((row, idx) => `<tr><td style="padding: 12px; background-color: #f2f2f2; border-bottom: 1px solid #dddddd; width: 30%; font-weight: bold; color: #0078DC;">${row.label}</td><td style="padding: 12px; border-bottom: 1px solid #dddddd; background-color: #f9f9f9;">${row.value}</td></tr>`).join('');
                    return `<table style="width: 100%; max-width: 640px; margin: 25px auto; border-collapse: collapse; font-size: 14px; border: 1px solid #dddddd; border-radius: 8px; overflow: hidden;"><tbody>${rowsHtml}</tbody></table>`;
                case ModuleType.TABLE_COL_HEADER:
                    const hHtml = (properties.headers || []).map(h => `<th style="padding: 12px; background-color: #f2f2f2; color: #0078DC; border: 1px solid #dddddd; text-align: left;">${h}</th>`).join('');
                    const bHtml = (properties.gridRows || []).map(r => `<tr>${r.cells.map(c => `<td style="padding: 12px; border: 1px solid #dddddd; background-color: #f9f9f9;">${c}</td>`).join('')}</tr>`).join('');
                    return `<table style="width: 100%; max-width: 640px; margin: 25px auto; border-collapse: collapse; font-size: 14px; border: 1px solid #dddddd; border-radius: 8px; overflow: hidden;"><thead><tr>${hHtml}</tr></thead><tbody>${bHtml}</tbody></table>`;
                case ModuleType.CTA:
                    return `<div style="margin-top: 25px; text-align: center; padding: 20px; background-color: #f9f9f9; border-radius: 8px;"><p style="margin-bottom: 15px; font-size: 13px; color: #666;">${properties.content}</p><a href="${properties.url}" style="background-color: #0078DC; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;">${properties.buttonText}</a></div>`;
                case ModuleType.FOOTER_BANNER:
                    return `<div style="text-align: center; margin-top: 20px;"><img src="${properties.imageUrl}" width="640" style="display: block; width: 100%; max-width: 640px; height: auto;"></div>`;
                case ModuleType.SIGNATURE:
                    return `<p style="font-size: 11px; color: #999; text-align: center; margin-top: 20px;">${properties.content}</p><div style="text-align: right; margin-top: 40px;"><img src="${properties.imageUrl}" style="display: inline-block; height: 40px;"></div>`;
                default: return '';
            }
        };

        const generateFullHtml = (modules) => {
            const content = modules.map(m => renderModuleToHtml(m)).join('\n');
            return `<!DOCTYPE html><html><body style="background-color: #f4f4f4; padding: 20px 0;"><div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 640px; margin: auto; background-color: #ffffff; color: #333; padding: 20px; border-radius: 8px;">${content}</div></body></html>`;
        };

        const ModuleItemEditor = ({ module, onChange, onRemove, onMoveUp, onMoveDown }) => {
            const updateProp = (key, value) => onChange(module.id, { ...module.properties, [key]: value });
            return React.createElement('div', { className: 'bg-white border border-slate-200 rounded-xl p-4 mb-4 shadow-sm' }, [
                React.createElement('div', { className: 'flex justify-between items-center mb-3 pb-2 border-b border-slate-100', key: 'h' }, [
                    React.createElement('span', { className: 'bg-blue-100 text-blue-700 text-[9px] font-bold px-2 py-1 rounded uppercase', key: 'p' }, module.type.replace(/_/g, ' ')),
                    React.createElement('div', { className: 'flex gap-1', key: 'b' }, [
                        React.createElement('button', { onClick: () => onMoveUp(module.id), className: 'p-1 hover:bg-slate-100 rounded text-slate-500', key: 'u' }, '↑'),
                        React.createElement('button', { onClick: () => onMoveDown(module.id), className: 'p-1 hover:bg-slate-100 rounded text-slate-500', key: 'd' }, '↓'),
                        React.createElement('button', { onClick: () => onRemove(module.id), className: 'p-1 hover:bg-red-50 text-red-400 rounded', key: 'r' }, '✕')
                    ])
                ]),
                React.createElement('div', { className: 'space-y-3', key: 'c' }, [
                    module.properties.title !== undefined && React.createElement('input', { key: 't', placeholder: 'Title', value: module.properties.title, onChange: e => updateProp('title', e.target.value), className: 'w-full text-xs border rounded p-1.5 outline-none' }),
                    module.properties.content !== undefined && React.createElement('textarea', { key: 'cn', placeholder: 'Content', value: module.properties.content, onChange: e => updateProp('content', e.target.value), className: 'w-full text-xs border rounded p-1.5 outline-none resize-none' }),
                    module.type === ModuleType.TABLE_ROW_HEADER && React.createElement('div', { className: 'space-y-1', key: 'tr' }, 
                        module.properties.rows?.map((r, i) => React.createElement('div', { className: 'flex gap-1', key: i }, [
                            React.createElement('input', { value: r.label, onChange: e => { const nr = [...module.properties.rows]; nr[i].label = e.target.value; updateProp('rows', nr); }, className: 'w-1/3 text-[10px] border rounded p-1 outline-none font-medium text-blue-700' }),
                            React.createElement('input', { value: r.value, onChange: e => { const nr = [...module.properties.rows]; nr[i].value = e.target.value; updateProp('rows', nr); }, className: 'flex-1 text-[10px] border rounded p-1 outline-none' })
                        ]))
                    ),
                    module.type === ModuleType.TABLE_COL_HEADER && React.createElement('div', { className: 'space-y-2', key: 'tch' }, [
                        React.createElement('div', { className: 'overflow-x-auto pb-1 custom-scrollbar', key: 'hscroll' }, 
                            React.createElement('div', { className: 'flex gap-1 min-w-max' }, 
                                module.properties.headers?.map((h, i) => React.createElement('input', { key: i, value: h, onChange: e => { const nh = [...module.properties.headers]; nh[i] = e.target.value; updateProp('headers', nh); }, className: 'w-20 text-[10px] border border-blue-50 bg-blue-50/30 rounded p-1 outline-none font-bold text-blue-700' }))
                            )
                        ),
                        React.createElement('div', { className: 'overflow-x-auto pb-1 custom-scrollbar', key: 'bscroll' }, 
                            React.createElement('div', { className: 'min-w-max space-y-1' }, 
                                module.properties.gridRows?.map((r, ri) => React.createElement('div', { className: 'flex gap-1', key: ri }, 
                                    r.cells.map((c, ci) => React.createElement('input', { key: ci, value: c, onChange: e => { const ng = [...module.properties.gridRows]; const nc = [...ng[ri].cells]; nc[ci] = e.target.value; ng[ri] = { cells: nc }; updateProp('gridRows', ng); }, className: 'w-20 text-[10px] border rounded p-1 outline-none' }))
                                ))
                            )
                        )
                    ])
                ])
            ]);
        };

        const App = () => {
            const [modules, setModules] = useState(DEFAULT_MODULES);
            const [activeTab, setActiveTab] = useState('preview');
            const [copySuccess, setCopySuccess] = useState(false);
            const fullHtml = useMemo(() => generateFullHtml(modules), [modules]);

            const addModule = (type) => {
                const id = `m-${Date.now()}`;
                let props = { content: 'Sample text' };
                if (type === ModuleType.TABLE_ROW_HEADER) props = { rows: [{label: 'Key', value: 'Value'}] };
                if (type === ModuleType.TABLE_COL_HEADER) props = { headers: ['Col 1', 'Col 2'], gridRows: [{cells: ['Data 1', 'Data 2']}] };
                setModules([...modules, { id, type, properties: props }]);
            };

            return React.createElement('div', { className: 'flex h-screen overflow-hidden' }, [
                React.createElement('div', { className: 'w-80 border-r flex flex-col h-full bg-white z-10', key: 's' }, [
                    React.createElement('div', { className: 'h-12 px-4 border-b flex justify-between items-center bg-slate-50' }, [
                        React.createElement('div', { className: 'flex items-center gap-2' }, [
                            React.createElement('img', { src: 'https://raw.githubusercontent.com/Uniper-Bulawa/dot-email-assets/main/DOT_small_bm.png', className: 'h-[18px] w-auto' }),
                            React.createElement('div', { className: 'h-4 w-px bg-slate-300' }),
                            React.createElement('span', { className: 'font-bold text-xs' }, 'Builder')
                        ]),
                        React.createElement('div', { className: 'relative group' }, [
                            React.createElement('button', { className: 'bg-blue-600 text-white text-[10px] px-2 py-1 rounded' }, 'ADD'),
                            React.createElement('div', { className: 'absolute right-0 mt-1 w-40 bg-white border rounded shadow-xl invisible group-hover:visible' }, 
                                Object.values(ModuleType).map(t => React.createElement('button', { key: t, onClick: () => addModule(t), className: 'w-full text-left px-3 py-2 text-[10px] hover:bg-slate-50 border-b last:border-0' }, t.replace(/_/g, ' ')))
                            )
                        ])
                    ]),
                    React.createElement('div', { className: 'flex-1 overflow-y-auto p-3 custom-scrollbar' }, 
                        modules.map(m => React.createElement(ModuleItemEditor, { key: m.id, module: m, onChange: (id, p) => setModules(modules.map(x => x.id === id ? {...x, properties: p} : x)), onRemove: id => setModules(modules.filter(x => x.id !== id)), onMoveUp: id => { const i = modules.findIndex(x => x.id === id); if (i > 0) { const nm = [...modules]; [nm[i], nm[i-1]] = [nm[i-1], nm[i]]; setModules(nm); } }, onMoveDown: id => { const i = modules.findIndex(x => x.id === id); if (i < modules.length - 1) { const nm = [...modules]; [nm[i], nm[i+1]] = [nm[i+1], nm[i]]; setModules(nm); } } }))
                    )
                ]),
                React.createElement('div', { className: 'flex-1 flex flex-col', key: 'm' }, [
                    React.createElement('div', { className: 'h-12 border-b bg-white flex items-center justify-between px-6' }, [
                        React.createElement('div', { className: 'flex bg-slate-100 p-0.5 rounded' }, [
                            React.createElement('button', { onClick: () => setActiveTab('preview'), className: `px-3 py-1 text-[10px] font-bold rounded ${activeTab === 'preview' ? 'bg-white shadow text-blue-600' : 'text-slate-500'}` }, 'Preview'),
                            React.createElement('button', { onClick: () => setActiveTab('code'), className: `px-3 py-1 text-[10px] font-bold rounded ${activeTab === 'code' ? 'bg-white shadow text-blue-600' : 'text-slate-500'}` }, 'Code')
                        ]),
                        React.createElement('button', { onClick: () => { navigator.clipboard.writeText(fullHtml); setCopySuccess(true); setTimeout(() => setCopySuccess(false), 2000); }, className: 'text-[10px] font-bold px-3 py-1.5 bg-slate-900 text-white rounded' }, copySuccess ? 'Copied!' : 'Copy')
                    ]),
                    React.createElement('div', { className: 'flex-1 overflow-auto p-6 bg-slate-100' }, 
                        activeTab === 'preview' 
                        ? React.createElement('iframe', { srcDoc: fullHtml, className: 'w-full h-full border bg-white rounded-lg shadow-lg' })
                        : React.createElement('pre', { className: 'bg-slate-900 text-blue-300 p-4 rounded text-xs h-full' }, fullHtml)
                    )
                ])
            ]);
        };

        ReactDOM.createRoot(document.getElementById('root')).render(React.createElement(App));
    </script>
</body>
</html>