import React from 'react';
import TeX from '@matejmazur/react-katex';
import './HistoryElement.css';

export class HistoryElement extends React.Component {
    constructor(props) {
        super(props);

        this.elementClick = this.elementClick.bind(this);
    }

    elementClick() {
        this.props.handleClick(this.props.historyItem);
    }

    getHistoryItemOutput() {
        const item = this.props.historyItem;
        if (item.output !== "") {
            return item.input + ' = ' + item.output;
        } else {
            return item.input;
        }
    }

    render() {
        return (
            <div className="history-item-div" onClick={this.elementClick}>
                <div>
                    <TeX
                        math={this.getHistoryItemOutput()}
                        errorColor={'#cc0000'}
                        settings={{ macros: { '\\dd': '\\mathrm{d}' } }}
                    />
                </div>
            </div>
        );
    }
}
