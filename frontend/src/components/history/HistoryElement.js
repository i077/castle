import React from 'react';
import TeX from '@matejmazur/react-katex';
import './HistoryElement.css';
import { KatexSettings } from "../KatexSettings";

export class HistoryElement extends React.Component {
    constructor(props) {
        super(props);

        this.elementClick = this.elementClick.bind(this);
    }

    elementClick() {
        this.props.handleClick(this.props.historyItem);
    }

    getHistoryItemInput() {
        const item = this.props.historyItem;
        return item.input;
    }

    getHistoryItemOutput() {
        const item = this.props.historyItem;
        return item.output;
    }

    getHistoryItemError() {
        const item = this.props.historyItem;
        return item.error;
    }

    render() {
        return (
            <div className="history-item-div" onClick={this.elementClick}>
                <div className="history-item-id-div">
                    [{this.props.historyItem.id}]
                </div>
                <div className="history-item-textinput-div">
                    <TeX
                        math={this.getHistoryItemInput()}
                        errorColor={'#cc0000'}
                        settings={KatexSettings}
                    />
                </div>
                <div className={!this.getHistoryItemError() ? "history-item-textoutput-div" : "history-item-texterror-div"}>
                    {!this.getHistoryItemError() ?
                        <TeX
                            math={this.getHistoryItemOutput()}
                            errorColor={'#cc0000'}
                            settings={KatexSettings}
                        />
                        : <code>{this.getHistoryItemError()}</code>
                    }
                </div>
            </div>
        );
    }
}
